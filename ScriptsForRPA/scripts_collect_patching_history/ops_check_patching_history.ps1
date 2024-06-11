[string] $Server = $args[0]
[string] $ExportFile = $args[1]

Write-Host "Date: "-NoNewline
Get-Date -format 'u'
Write-Host "Server: "-NoNewline 
$Server
Write-Host "Whoami: "-NoNewline 
whoami
Write-Host "Export File: $ExportFile"

Get-Hotfix -ComputerName $Server | Export-Csv $ExportFile