$Servers = @("XE-S-XHFMTM01S.xe.abb.com", "XE-S-XHFMDEV01D.xe.abb.com", "XE-S-XHFMTM01P.xe.abb.com", "XE-S-XHFMFE01P.xe.abb.com", "XE-S-XHFMFE02P.xe.abb.com", "XE-S-XHFMAP01P.xe.abb.com", "XE-S-XHFMAP02P.xe.abb.com", "XE-S-XHFMAP03P.xe.abb.com", "XE-S-XHFMAP04P.xe.abb.com", "XE-S-XHFMDB01P.xe.abb.com", "XE-S-XHFMDB02P.xe.abb.com", "XE-S-XHFMFE01S.xe.abb.com", "XE-S-XHFMAP01S.xe.abb.com", "XE-S-XHFMAP01S.xe.abb.com", "XE-S-XHFMAP02S.xe.abb.com", "XE-S-XHFMDB01S.xe.abb.com")
#$Servers = @("XE-S-XHFMDB01S.xe.abb.com")

foreach ($Server in $Servers) {

    Invoke-Command -ComputerName $Server -ScriptBlock {start-service -Name nscp}
}
<#
    if ((Invoke-Command -ComputerName $Server -ScriptBlock {Test-Path "C:\Program Files\NSCLIENT++\*"})  )
    {
        Write-Host $Server
        Write-Host "File exists" -ForegroundColor Yellow
    }
    else {
        #Invoke-Command -ComputerName $Server -ScriptBlock {Robocopy.exe /S /E "\\pl-w-7000750.europe.abb.com\NSClient\NSClient++_0.5.2.35" "C:\Program Files\NSCLIENT++" *.*} 
        $destinationPath = "\\" + $Server + "\" + "C$\Program Files\NSCLIENT++"
        Write-Host $destinationPath -ForegroundColor Magenta
        Write-Host $Server
        Robocopy.exe /S /E "\\pl-w-7000750.europe.abb.com\NSClient$\NSClient++_0.5.2.35" $destinationPath *.*
        Write-Host "Files have been copied" -ForegroundColor Green
    }

} 
#>