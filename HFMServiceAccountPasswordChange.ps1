try{
    $LogPath = "$PSScriptRoot\HFMServiceAccountPasswordChange.log"
    $servers = @('XE-S-XHFMFE01S.xe.abb.com','XE-S-XHFMAP01S.xe.abb.com','XE-S-XHFMAP02S.xe.abb.com'<#,'XE-S-XHFMTM01S.xe.abb.com'#>)
    $serviceUserCredentialPath = "$PSScriptRoot\ServiceUserCredentials.xml"

    #Do not edit below this line-----------------------------------------------------------------------
    .("$PSScriptRoot\Functions.ps1")
    $serviceUserCredential = $null  #Current service user credentials
    if (Test-Path -Path $serviceUserCredentialPath)
    {
        $serviceUserCredential =  Import-Clixml $serviceUserCredentialPath
    }else
    {
        $serviceUserCredential = Get-Credential -Message "Please provide current service user credential." -UserName 'ABB\PL-XHFM-SVC-STG'
    }

    $userWithoutDomainName = $($serviceUserCredential.UserName -creplace '^[^\\]*\\', '')

    if ( -not (Get-ADUser -Server ABB.COM -LDAPFilter "(sAMAccountName=$userWithoutDomainName)")) {          
        throw "Can't find $userWithoutDomainName user in AD"
    }     

    Write-Log "INFO" "Credentials for user $($serviceUserCredential.UserName) has been provided."
    #Scan servers for services
    $allServices = 
        @(foreach ($server in $servers) {
            $filter = "StartName LIKE '%$userWithoutDomainName'" 
            $error.Clear()
            $services = @(Invoke-Command -ComputerName $server -ScriptBlock {
                $s = Get-WmiObject -Class Win32_Service -filter $Using:filter | Select-Object SystemName, Name, DisplayName, Status, State, StartMode, StartName 
                return $s;
            })
            if ($error.Count -gt 0) { throw $error[0] }
            Write-Log "INFO" "$($services.Count) services using user $($serviceUserCredential.UserName) found on server $server "
            $services 
        })

    #Scan servers for IIS pools
        $allPools = 
        @(foreach ($server in $servers) {
            $filter = $serviceUserCredential.UserName
            $error.Clear()            
            $pools = @(Invoke-Command -ComputerName $server -ScriptBlock {
                if (Get-Module -ListAvailable -Name WebAdministration) {
                    Import-Module WebAdministration
                    $p = @(Get-ChildItem -Path IIS:\AppPools\ | Select-Object name, state, managedPipelineMode, @{e={$_.processModel.username};l="username"})
                    return $p | Where-Object username -EQ $Using:filter;
                } else 
                {
                    continue
                }
            })
            if ($error.Count -gt 0) { throw $error[0] }            
            Write-Log "INFO" "$($pools.Count) IIS pools using user $($serviceUserCredential.UserName) found on server $server "
            $pools 
        })
    

    $allServices | Select-Object PSComputerName, Name, Status, State, StartMode, StartName | Format-Table
    $allPools | Format-Table

    if (@($allServices | ?{$_.State -ne "Stopped"}).Length -gt 0 )
    {
        Write-Log "ERROR" "Some services are running. Is not recommended to change the password"
    }

    $serviceUserNewCredential = $null
    $newPassword = $null;
    $confirmation = Read-Host "Do you want to generate a new password for $($serviceUserCredential.UserName)? [Y/N]"
    if ($confirmation -eq 'y') {
        $newPassword = GenerateStrongPassword(20)
        $secureNewPassword = ConvertTo-SecureString $newPassword -AsPlainText -Force
        [pscredential]$serviceUserNewCredential = New-Object System.Management.Automation.PSCredential ($serviceUserCredential.UserName, $secureNewPassword)
        Write-Log "INFO" "The new password was generated for user $($serviceUserCredential.UserName) [$newPassword]"       
    }else
    {
        $serviceUserNewCredential = Get-Credential -Message "Please provide a new password." -UserName $serviceUserCredential.UserName
        $newPassword = [System.Net.NetworkCredential]::new("", $serviceUserNewCredential.Password).Password
    }

    $confirmation = Read-Host "Do you want to change the password in AD for $($serviceUserCredential.UserName)? [Y/N]"
    if ($confirmation -eq 'y') {
        Set-ADAccountPassword  -WhatIf -Server ABB.COM -OldPassword $serviceUserCredential.Password -NewPassword $serviceUserNewCredential.Password -Identity $userWithoutDomainName
        Write-Log "INFO" "The new password for user $($serviceUserCredential.UserName) has been changed in AD"       
    }
    
    $serviceUserCredential | Export-CliXml "$PSScriptRoot\ServiceUserCredentials $(get-date -f yyyyMMddTHHmmssZ).xml"  
    $serviceUserNewCredential | Export-CliXml $PSScriptRoot\ServiceUserCredentialsNew.xml

    foreach ($service in $allServices)
    {        
        Read-Host -Prompt "Press enter to change Passwords for the service $($service) or CTRL+C to quit"
        Write-Log "INFO" "Changing password for service $($service.Name) on computer $($service.PSComputerName)"
        $result = Invoke-Command -ComputerName $service.PSComputerName -ScriptBlock {
            $svc = Get-WmiObject -Class win32_service -filter "Name='$($Using:service.Name)'"
            $result = $svc.change($null,$null,$null,$null,$null,$null,$null,$Using:newPassword) | Select-Object ReturnValue
            $result
        }
        if ($result.ReturnValue -ne 0)
        {
            Write-Log "ERROR" "Changing password for $($service.Name) failed on server $($service.PSComputerName) with result=$($result.ReturnValue)"
        }
    }

    foreach ($pool in $allPools)
    {        
        Write-Log "INFO" "Changing password for IIS pool $($pool.name) on computer $($pool.PSComputerName)"
        Invoke-Command -ComputerName $pool.PSComputerName -ScriptBlock {
            Import-Module WebAdministration 
            $apppool = "IIS:\AppPools\" + $Using:pool.name
            Set-ItemProperty $apppool -name processModel.password -Value $Using:newPassword                    
        }
        Write-Log "INFO" "Password has been changed for IIS pool $($pool.name) on computer $($pool.PSComputerName). Remember to test the website."
    }


}catch{
    Write-Log "ERROR" "$_"
}
