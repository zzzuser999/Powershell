Function Check-Ports {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]$ServerName = "localhost",

        [Parameter(Mandatory)]
        [array]$PortRange
        
    )
    foreach ($Port in $PortRange) {
        If (($a=Test-NetConnection $ServerName -Port $Port -WarningAction SilentlyContinue).tcpTestSucceeded -eq $true){
            "TCP Port $Port is in-use!"
            If ($ServerName -eq "localhost") {
                Get-Process -Id (Get-NetTCPConnection -LocalPort $Port).OwningProcess
            } else {
              write-host "Run on $ServerName as localhost to see ProcessName using Port $Port "
            }

        } else {
            "TCP Port $Port is not in-use!"
        }   
    
    }
}

$ServerName = 'localhost'
$hsxPorts = 9091..9092
$xfmPorts = 10001..10020
$PortRange = $hsxPorts + $xfmPorts

Check-Ports -ServerName $ServerName -PortRange $PortRange