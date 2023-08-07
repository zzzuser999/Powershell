$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Security

function Write-Log {
    Param (
        [Parameter(Mandatory=$false)] [string]$Type, 
        [Parameter(Mandatory=$false)] $Message
	)
 
    $EventTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss:fff") 

	$LogMessage = "$EventTime | $Type $Message "
	$color = "Green"
	if($Type -eq "ERROR"){ $color="Red" }

	Write-Host -ForegroundColor $color $LogMessage
	$LogMessage | Out-File -Append -Encoding UTF8 -FilePath $LogPath
}

$LogPath = "$PSScriptRoot\LCMExportPasswordChange.log"
$XPath = "//Package/User[@password|@name='LCMExport']"
$connectionString = "Data Source=XE-S-XHFMDB01P.xe.abb.com;Initial Catalog=EPMTools_Config; User Id=ABBEpmTools_prod_dbo;Password=KZ75y3YS9cnkSUpYuoHu" 

try {
    #Get password for user 'LCMExport' from AccountSetupTool
    $query = "SELECT [Value] FROM [dbo].[GlobalSettings] WHERE Name='EncryptedAdminPassword$env:computername'"

    $sqlDataAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter($query, $connectionString)
    $dataTable = New-Object -TypeName System.Data.DataTable
    [void]$sqlDataAdapter.Fill($dataTable)
    $protectedString  = $dataTable.Rows[0]["Value"]
    Write-Log "INFO" "The password has been found in database."

    #Decode password
    $enc = [system.Text.Encoding]::Default
    $protectedBytes = $enc.GetBytes($protectedString) 
    $rawKey = [System.Security.Cryptography.ProtectedData]::Unprotect($protectedBytes, $null, [System.Security.Cryptography.DataProtectionScope]::LocalMachine)
    $pass = $enc.GetString($rawKey)
    Write-Log "INFO" "The password has been decoded sucessfully. $pass"
    
    #ReplacePassword in HssSecExport.xml 
    $fileXml = [xml](Get-Content "$PSScriptRoot\HssSecExport.xml")
    $targetNode = $fileXml.SelectSingleNode($XPath)
    $previousPassword = $targetNode.password
    $targetNode.SetAttribute('password', $pass)
    $fileXml.Save("$PSScriptRoot\HssSecExport.xml")
    Write-Log "INFO" "Password has been replaced in HssSecExport.xml."

    #Execute 2.HSSSecExport.bat to hash password
    & "$PSScriptRoot\2.HSSSecExport.bat"
    $exitCode = $LastExitCode
    Write-Log "INFO" "2.HSSSecExport.bat has been executed. Last exit code: $exitCode"

    #Check if password has changed and update other XML's
    $fileXml = [xml](Get-Content "$PSScriptRoot\HssSecExport.xml")
    $targetNode = $fileXml.SelectSingleNode($XPath)

    
    if ($targetNode.password -eq $pass -or $exitCode -ne 0) {
        #Something went wrong. Need to restore previous password to prevent from keeping open text secrets.
        $targetNode.SetAttribute('password', $previousPassword)
        $fileXml.Save("$PSScriptRoot\HssSecExport.xml")
        Write-Log "ERROR" "The Password has not been hashed. Previous password has been restored in HssSecExport.xml."
    }else {
        Write-Log "INFO" "Password has beeen hashed sucessfully. Replacing passwords in other xmls."
        Get-ChildItem -Path "$PSScriptRoot" -Filter "*.xml" | Where-Object {$_.Name -ne 'HssSecExport.xml'} | Foreach-Object {
            $subFileXml = [xml](Get-Content $_.FullName)
            $subTargetNode = $subFileXml.SelectSingleNode($XPath)
            if ($subTargetNode.password -ne $targetNode.password){
                $subTargetNode.SetAttribute('password', $targetNode.password)           
                $subFileXml.Save($_.FullName)
                Write-Log "INFO" "Password has been modified in file $_.FullName."
            }
            
        }
    }
}catch{
    Write-Log "ERROR" "$_"
}