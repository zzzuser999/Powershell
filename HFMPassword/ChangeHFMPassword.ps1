try {
    $LogPath = "$PSScriptRoot\HFMPasswordChange.log"
	$connectionString = "Data Source=XE-S-XHFMDB01P.xe.abb.com;Initial Catalog=EpmTools_config;Persist Security Info=True;User ID=ABBEpmTools_prod_dbo;Password=KZ75y3YS9cnkSUpYuoHu"
	$dbName = "EpmTools_config"
	$hssUrl = "http://127.0.0.1:8448"
	$rowPrefixPass= "EncryptedAdminPassword" 
	$rowPrefixUser= "AdminUser"
	$hfmUserName= "LCMExport"
	$hoursToNextChange = 24*30

    
    #Do not edit below this line-----------------------------------------------------------------------

    . ("$PSScriptRoot\Functions.ps1")
    $enc = [system.Text.Encoding]::Default
    if (-not(Test-Path -Path $PSScriptRoot\HSSCredentials.xml -PathType Leaf)) {
        throw "HSS Credentials file not found. Plese execute GenerateHSSCredentials.ps1"
    }
    $hssCredential = Import-Clixml HSSCredentials.xml
    $connection = New-Object System.Data.SQLClient.SQLConnection($connectionString)
    $connection.Open()

    #Get the password and username from database
    $query = "SELECT [Name], [Value], [Modified], [PreviousValue] FROM [$dbName].[dbo].[GlobalSettings] `
              WHERE Name='$rowPrefixPass$env:computername' OR Name = '$rowPrefixUser$env:computername'"

    $sqlDataAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter($query, $connection)
    $dataTable = New-Object -TypeName System.Data.DataTable
    [void]$sqlDataAdapter.Fill($dataTable)
    foreach($row in $dataTable.Rows)
    {
        switch ($row["Name"]) {
            "$rowPrefixPass$env:computername" {
                $secret  = $row["Value"]
                $secretModified = $row["Modified"]
                #$secretPreviousValue = $row["PreviousValue"]
                break;
            }
            "$rowPrefixUser$env:computername" {
                $userName = $row["Value"]
                break;
            }
            Default {
                throw "DB Query result doesn't contain secret." 
            }
        }
    }
    
    if ($hfmUserName -ne $userName)
    {
        throw "Definied user $hfmUserName is different than the user stored int the DB [$userName]."
    } 

    Write-Log "INFO" "The password for $userName last modified $secretModified has been found in database."    

    #If password has been modified during last x hours dont't update it
    $lastChangeTimeSpan =  ((Get-Date) - $secretModified)
    if($lastChangeTimeSpan.TotalHours -lt $hoursToNextChange) 
    {   
        Write-Log "INFO" "The password was updated $([int]$lastChangeTimeSpan.TotalHours) hours ago. No need to update."
        return 0
    }
    
    #Generate a new strong HFM password
    $newPassword = GenerateStrongPassword(20);    
    Write-Log "INFO" "The password for $userName has been generated successfully"
    #Encrypt & update new password in DB
    Write-Log "INFO" "Trying to change password for $userName in the database $dbName."    
    $rawNewKey = [System.Security.Cryptography.ProtectedData]::Protect($enc.GetBytes($newPassword), $null, [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
    Write-Log "INFO" "Secret for user $userName has been encrypted."
    $query = "UPDATE [$dbName].[dbo].[GlobalSettings] SET [Value] = @SECRET WHERE Name='$rowPrefixPass$env:computername'"
    $command = New-Object System.Data.SQLClient.SQLCommand($query, $connection)  
    [void]$command.Parameters.Add("@SECRET", [System.Data.SqlDbType]::NVarChar); 
    $command.Parameters["@SECRET"].Value = $enc.GetString($rawNewKey);
    $rowsAffected = $command.ExecuteNonQuery()     
    Write-Log "INFO" "Secret for user $userName has been updated in the db [RowsAffected = $rowsAffected]" 

    #Update the new passsword in HFM
    try 
    {
        $rawCurrentKey = [System.Security.Cryptography.ProtectedData]::Unprotect($enc.GetBytes($secret), $null, [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
        $json = @{oldPassword=$enc.GetString($rawCurrentKey);newPassword=$newPassword} | ConvertTo-Json -Compress
        Write-Log "INFO" "Trying to change password for $userName using HSS $hssUrl."    
        $requestResult = Invoke-WebRequest -Uri "$hssUrl/setUserPassword/$userName" -Credential $hssCredential -Body $json -ContentType application/json -Method Post -UseBasicParsing
        if($requestResult.Content -clike "Password changed")
        {
            Write-Log "INFO" "The password for $userName has been changed. $($requestResult.Content)"
        }
        else {
            throw "[Code: $($requestResult.StatusCode)] Cannot change the password - $($requestResult.Content)"
        }    
    }
    catch {
        #Restore old password in DB
        Write-Log "ERROR" "$_"
        Write-Log "INFO" "Restoring the old secret from PreviousValue [RowsAffected = $rowsAffected]"     
        $query = "UPDATE [$dbName].[dbo].[GlobalSettings] SET [Value] = [PreviousValue] WHERE Name='$rowPrefixPass$env:computername'"
        $command = New-Object System.Data.SQLClient.SQLCommand($query, $connection)  
        $rowsAffected = $command.ExecuteNonQuery()     
        Write-Log "INFO" "Secret for user $userName has been restored in db [RowsAffected = $rowsAffected]"     
    }

    $connection.Close()
    return 0
}catch{
    Write-Log "ERROR" "$_"
   
}