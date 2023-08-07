[string] $Server = 'XE-S-HFMFE02P.xe.abb.com'
[string] $ExportFile = 'C:\Temp\patches20210729.csv'

 

Write-Host "Date: "-NoNewline
Get-Date -format 'u'
Write-Host "Server: "-NoNewline 
$Server
Write-Host "Whoami: "-NoNewline 
whoami
Write-Host "Export File: $ExportFile"

 

Get-Hotfix -ComputerName $Server | Export-Csv $ExportFile