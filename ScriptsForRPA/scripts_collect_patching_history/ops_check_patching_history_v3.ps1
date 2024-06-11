#Usage: ops_check_patching_history.ps1 <server_name> <export_file> 



[string] $Server = $args[0]

[string] $ExportFile = $args[1]



Write-Host "Date: "-NoNewline

Get-Date -format 'u'

Write-Host "Server: "-NoNewline 

$Server

Write-Host "Whoami: "-NoNewline 

whoami

Write-Host "Export File: $ExportFile"



Get-SqlAgent -ServerInstance $Server | Get-SqlAgentJob | Select-Object Name, DateCreated, DateLastModified, OriginatingServer, `

OwnerLoginName, IsEnabled, LastRunDate, LastRunOutcome, NextRunDate | Export-Csv $ExportFile