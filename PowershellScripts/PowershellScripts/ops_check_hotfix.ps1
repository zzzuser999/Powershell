$File = "$PSScriptRoot\servers.txt"
$Servers = Get-Content $File
$ExportFileLocation = "$PSScriptRoot"

Clear-Host


Foreach ($Server in $Servers)
{
    Get-Hotfix -ComputerName $Server
}