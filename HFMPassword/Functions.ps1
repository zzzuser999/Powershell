Function GenerateStrongPassword ([Parameter(Mandatory = $true)][int]$PasswordLenght) {
    Add-Type -AssemblyName System.Web
    $PassComplexCheck = $false
    do {
        $newPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLenght, 1)
        If ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
                -and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
                -and ($newPassword -match "[\d]") `
                -and ($newPassword -match "[^\w]") `
                -and ($newPassword -notmatch "[<>&'`"]") #XML invalid characters
        ) {
            $PassComplexCheck = $True
        }
    } While ($PassComplexCheck -eq $false)
    return $newPassword
}

Function Write-Log {
    Param (
        [Parameter(Mandatory = $false)] [string]$Type, 
        [Parameter(Mandatory = $false)] $Message
    ) 
    $EventTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss:fff") 
    $LogMessage = "$EventTime | $Type $Message "
    $color = "Green"
    if ($Type -eq "ERROR") { $color = "Red" }
    Write-Host -ForegroundColor $color $LogMessage
    $LogMessage | Out-File -Append -Encoding UTF8 -FilePath $LogPath
}