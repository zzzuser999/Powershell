# server instance and default database
$server = 'XE-V-TMSDBP02\TMSPROD'
$database = 'master'

# folder with the scripts and additional variables
$scriptsfolder = "$(Resolve-Path .)\Scripts"
$path = ($(Resolve-Path .)).Path
$date = Get-Date -Format 'yyyy-MM-dd'

# get a list of all scripts that need to be executed
$scripts = Get-ChildItem FileSystem::$scriptsFolder | Where-Object {$_.Extension -eq '.sql'}

# moving old result files to archive
Get-ChildItem FileSystem::$path | Where-Object {$_.Extension -eq '.csv'} | Move-Item -Destination "$($path)\Archive" -Force | Out-Null

# execvution
Write-Host `n"UAM1_GBS DB layer - $($server)" -ForegroundColor Cyan

# verify if script folder is empty
If($scripts.Count -eq 0){
    Write-Host `n'Scripts folder is empty. No scripts are available.' -ForegroundColor Yellow
}
Else{
    # show the modify date, length and the name of the files
    Write-Host `n"Scripts files that will be executed on $($server) SQL instance:"
    $scripts | Select-Object Name, LastWriteTime, Length | Format-Table -AutoSize
    
    # execute the script, export the results and count it in the loop
    Foreach($file in $scripts){#$file}
        Write-Host "Running script $($file.Name)..." -ForegroundColor Yellow
        $fullname = $file.FullName
        Try{
            $result = Invoke-Sqlcmd -ServerInstance $server -Database $database -InputFile $fullname -QueryTimeout 65555 -ErrorAction Stop
            If(-not !$result){
                $resultFileName = Join-Path -Path $path -ChildPath "$($date)--$($file.name)-results.csv"
                $result | Export-Csv -Path "$resultFileName" -Delimiter ';' -NoTypeInformation -Force
                Write-Host 'Script' $file.Name 'executed successfully' -ForegroundColor Green
                Write-Host "Results saved to file $resultFileName" -ForegroundColor Green
                $rowCount = ($result | Measure-Object).Count
                Write-Host "$rowCount row's affected"`n
            }
        }
        Catch{
            Write-Host 'Script' $file.Name 'ended with errors in' $server -ForegroundColor Red
        }
    }
}

Invoke-Sqlcmd -ServerInstance $server -Database $database -InputFile $fullname -QueryTimeout 65555 -ErrorAction Stop