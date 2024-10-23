$SQLServer = "XC-S-ZW01641.xc.abb.com"
$IISServer = "XC-S-ZW01639.xc.abb.com"

$Credentials = Get-Credential

invoke-command -computername $SQLServer -scriptblock {Invoke-Sqlcmd -Query "truncate table CacheEntry;" -ServerInstance $SQLServer -Database "CognosDM_Cache"} -Credential $Credentials
invoke-command -computername $IISServer -scriptblock {iisreset /RESTART} -Credential $Credentials