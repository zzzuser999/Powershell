$Servers = 
"xe-s-HFMFE01P.xe.abb.com",
"xe-s-HFMFE02P.xe.abb.com",
"xe-s-HFMAP01P.xe.abb.com",
"xe-s-HFMAP02P.xe.abb.com",
"xe-s-HFMAP03P.xe.abb.com",
"XE-S-HFMDB01P.xe.abb.com",
"XE-S-HFMDB02P.xe.abb.com",
"de-s-CH00105.xe.abb.com"


Foreach ($Server in $Servers)
{
    $Server
    Get-Date -Format "yyyy-MM-dd HH:MM:ss"
    schtasks.exe /query /s $Server /V /FO CSV | ConvertFrom-Csv |  Where { $_.HostName -eq $Server -and $_.TaskName -notmatch "Microsoft" } | Select HostName,TaskName, "Next Run Time", Status, "Last Run Time", "Last Result", Author, "Scheduled Task State" | Format-Table -Wrap -AutoSize | Export-Csv ".\$Server.csv"

}