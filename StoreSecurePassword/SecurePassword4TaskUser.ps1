# Step 1: Convert the plain text password to a secure string
$securePassword = ConvertTo-SecureString "LW5U5ibTXcxsyNJrqRJLA7gFquEPPM" -AsPlainText -Force

# Step 2: Convert the secure string to an encrypted standard string
$encryptedPassword = $securePassword | ConvertFrom-SecureString

# Step 3: Save the encrypted string to a file
$encryptedPassword | Out-File "S:\ABBOps\Scripts\SchTasksSettings\SecurePassword.txt"


<#
Read the password from the secure file
$passwordFile = 'S:\ABBOps\Scripts\SchTasksSettings\SecurePassword.txt'
$securePassword = Get-Content $passwordFile | ConvertTo-SecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
#>