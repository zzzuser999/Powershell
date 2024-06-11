[string] $Server = 'XE-S-HFMFE02P.xe.abb.com'
[string] $ExportFile = 'C:\Temp\schtasks.csv'

Write-Host "date: "-NoNewline
Get-Date -format 'u'
Write-Host "server: "-NoNewline
$Server
Write-Host "whoami: "-NoNewline
whoami

schtasks.exe /query /s $Server /V /FO CSV | ConvertFrom-Csv | Where {$_.TaskName -notmatch "TaskName" -and $_.TaskName -notmatch "Microsoft" } |`
Select-Object HostName,TaskName, "Next Run Time", Status, "Last Run Time", "Last Result", Author, "Scheduled Task State" | Export-Csv $ExportFile