$application = "*Visual C++ 2010*"
$servers = @("XE-S-NHFMTM01P.xe.abb.com","XE-S-NHFMFE01P.xe.abb.com","XE-S-NHFMFE02P.xe.abb.com","XE-S-NHFMAP01P.xe.abb.com","XE-S-NHFMAP02P.xe.abb.com","XE-S-NHFMAP03P.xe.abb.com")
#$servers = @("localhost")
$results =@()

foreach ($server in $servers) 
{
    $condition = (Invoke-Command -Cn $server -ScriptBlock { Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ `
        | Get-ItemProperty | where {$_.DisplayName -like $using:application } | Select-Object DisplayName,DisplayVersion }).DisplayName
        
    if ($condition){$results += "VC++ redist 2010 found on: " +$server +"`n"}
    else {$results += "VC++ redist 2010 not installed on: " + $server +"`n"}
}

Write-Host "Servers checked: " $servers -BackgroundColor Green
Write-Host $results -ForegroundColor Magenta