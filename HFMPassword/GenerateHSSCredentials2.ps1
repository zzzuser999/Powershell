$userName = 'hssUser' 
$password = 'xxx' 
$pwdSecureString = ConvertTo-SecureString -Force -AsPlainText $password 
New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $pwdSecureString | Export-CliXml HSSCredentials.xml