Param (
<#[parameter(Mandatory=$true)]
[alias("f")]
[String[]] $strFileName, 
#>
[parameter(Mandatory=$true)]
[alias("u")]
[String[]] $strUserName
)
$strDate = get-date -Format "yyyyMMdd"
$strLogFile = "PyramidCopy_" + $strDate + ".log"
$tabServers = Import-Csv -Path .\PyramideServers.csv
$strABB = "\\pl-w-7000750\d$\ABBInstaller\"
$strFileName = get-childitem -Path $strABB Pyramid* | Sort-Object Lastaccesstime -Descending | Select-Object -First 1
$strSourcePath = $strABB
#Write-Host $tabServers

foreach ($strDest in $tabServers)
{
$strDestDesktop = "\\" + $strDest.Server + "\c$\users\" + $strUserName + "\Desktop"
Write-Host "Copying " $strFileName " to " $strDestDesktop -ForegroundColor Yellow
robocopy.exe $strSourcePath $strDestDesktop $strFileName /XO /MT:32 /R:3 /W:1 /LOG+:$strLogFile
write-host "Installation file successfully copied to " $strDestDesktop -ForegroundColor Green
}
Write-host "Newest installation file has been copied to Prod and DR environment! `n Press any key to continue... " -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
