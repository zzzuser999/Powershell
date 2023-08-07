[string] $Server = "XC-S-ZW09302.xc.abb.com"
[string] $ExportFile = "sql.csv"
Write-Host "Date: "-NoNewline
Get-Date -format 'u'
Write-Host "Server: "-NoNewline 
$Server
Write-Host "Whoami: "-NoNewline 
whoami
Write-Host "Export File: $ExportFile"

Get-SqlAgent -ServerInstance $Server | Get-SqlAgentJob | Select-Object Name, DateCreated, DateLastModified, OriginatingServer, ` OwnerLoginName, IsEnabled, LastRunDate, LastRunOutcome, NextRunDate | Format-Table -Wrap -AutoSize

Get-SqlAgent -ServerInstance $Server | Get-SqlAgentJob | Select-Object Name, DateCreated, DateLastModified, OriginatingServer, ` OwnerLoginName, IsEnabled, LastRunDate, LastRunOutcome, NextRunDate | Export-Csv $ExportFile