$Servers = @("XE-S-XHFMDEV01D.xe.abb.com")
$TargetDir = "c$\Program Files\NSCLIENT++"
$TargetDirLocal = "C:\Program Files\NSCLIENT++"
$TargetDirLocalFiles = $TargetDirLocal + "\*"

foreach ($Server in $Servers)
    {
        Enter-PSSession -ComputerName $Server
        if (!(Test-Path $TargetDirLocalFiles)) {
        write-host $TargetDirLocalFiles
        write-host "No files" -ForegroundColor Red
        }
        ELSE {
        write-host "Files already there" -ForegroundColor Green
        }
        Exit-PSSession
       }