#Usage: ops_check_patching_history.ps1 <server_name> <export_file> 



[string] $Server = $args[0]

[string] $ExportFile = $args[1]



Write-Host "date: "-NoNewline

Get-Date -format 'u'

Write-Host "server: "-NoNewline 

$Server

Write-Host "whoami: "-NoNewline 

whoami




schtasks.exe /query /s $Server /V /FO CSV | ConvertFrom-Csv |  Where {$_.TaskName -notmatch "TaskName" -and $_.TaskName -notmatch "Microsoft" } |`

    Select-Object HostName,TaskName, "Next Run Time", Status, "Last Run Time", "Last Result", Author, "Scheduled Task State" | Export-Csv $ExportFile