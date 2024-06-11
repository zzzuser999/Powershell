#$Servers = @("XE-S-XHFMDEV01D.xe.abb.com", "XE-S-XHFMTM01P.xe.abb.com", "XE-S-XHFMFE01P.xe.abb.com", "XE-S-XHFMFE02P.xe.abb.com", "XE-S-XHFMAP01P.xe.abb.com", "XE-S-XHFMAP02P.xe.abb.com", "XE-S-XHFMAP03P.xe.abb.com", "XE-S-XHFMAP04P.xe.abb.com", "XE-S-XHFMDB01P.xe.abb.com", "XE-S-XHFMDB02P.xe.abb.com", "XE-S-XHFMFE01S.xe.abb.com", "XE-S-XHFMAP01S.xe.abb.com", "XE-S-XHFMAP01S.xe.abb.com", "XE-S-XHFMAP02S.xe.abb.com", "XE-S-XHFMDB01S.xe.abb.com", "XF-S-XHFMDB02S.xe.abb.com")
$ServersDR = @("XF-S-XHFMTM01R.xe.abb.com", "XF-S-XHFMFE01R.xe.abb.com", "XF-S-XHFMAP01R.xe.abb.com", "XF-S-XHFMDB01R.xe.abb.com")
$TargetDir = "c$\Program Files\NSCLIENT++"
#$service = Get-Service -Name nscp

foreach ($Server in $ServersDR)
    {
        $Path = "\\" + $Server + "\" + $TargetDir
        if ((Test-Path $Path)){
        Write-Host $Server
        Write-Host "Path existis" -ForegroundColor Green
        }
        ELSE {
            New-Item -ItemType Directory $Path
            $destinationPath = "\\" + $Server + "\" + "C$\Program Files\NSCLIENT++"
        Write-Host $destinationPath -ForegroundColor Magenta
        Write-Host $Server
        Robocopy.exe /S /E "\\pl-w-7000750.europe.abb.com\NSClient$\NSClient++_0.5.2.35" $destinationPath *.*
        Write-Host "Files have been copied" -ForegroundColor Green
        }
        <#if ($service -eq $null) {
            'C:\Program Files\NSClient++\nscp.exe' service --install --name NSCP --description "NSClient++_0.5.2.35" 
        }#>
       }