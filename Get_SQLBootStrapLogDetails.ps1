$logfolder = "C:\Program Files\Microsoft SQL Server\140\Setup Bootstrap\Log\"
$DateFrom = "09/20/2023"
$DateTo = "01/01/2024"
$folders = Get-ChildItem $logfolder | ? { ($_.LastWriteTime -gt $DateFrom) -and ($_.LastWriteTime -lt $DateTo ) }

Clear

$Server = [System.Net.Dns]::GetHostByName($env:computerName).HostName
$DateNow = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ExportFile = "D:\ABBOps\SOX\SQLPatching_$server.csv"

Write-Host "############################"
whoami
Write-Host $Server
Write-Host $DateNow
Write-Host "############################"

$Raport = New-Object PSObject
$ReportList = @()

foreach($folder in $folders)
{
        $files = get-childitem $folder.FullName 
        [bool]$found = 0

        foreach($file in $files)
        {
            if ($file.Name -like "*Summary*")
            {
                $found = 1
                [string]$Content = Get-Content $file.FullName | Select-String "Requested action:" | select-object -First 1
                $Content = ($Content.Split(':')[1]).TrimStart()
                $Raport = [PSCustomObject]@{
                    FolderName = $folder.Name
                    RequestedAction = $Content       }
                $ReportList += $Raport            }       
             }

        if ($found -eq 0)
        {
           $Raport = [PSCustomObject]@{
                    FolderDate = $folder.Name
                    RequestedAction = "None"           }
           $ReportList += $Raport
        }
}

Write-Host "Count: " -NoNewline
$ReportList.Count
$ReportList | ft
$ReportList | Export-Csv $ExportFile -NoTypeInformation
Get-FileHash -Algorithm SHA256 -Path $ExportFile