$File = $args[0]
$Servers = Get-Content $File
$ExportFileLocation = "$PSScriptRoot"

Clear-Host

Foreach ($Server in $Servers)
{
    $Date = Get-Date -format 'u'

    Write-Host "date: "-NoNewline
    $Date
    Write-Host "server: "-NoNewline 
    $Server
    Write-Host "whoami: "-NoNewline 
    whoami   

    $ExportFile = $ExportFileLocation+"\SQL_Jobs-$Server.csv"
    
    $Result = Get-SqlAgent -ServerInstance $Server | Get-SqlAgentJob | Select-Object Name, DateCreated, DateLastModified, OriginatingServer, `
    OwnerLoginName, IsEnabled, LastRunDate, LastRunOutcome, NextRunDate | Format-Table

    $Result 
    $Result | Export-Csv $ExportFile
   
    Read-Host
    Clear-Host
}
