# Define the path to the KeePass database and the master password
$databasePath = "C:\Users\plmamro7\Documents\KeePass\MMR-Private.kdbx"
$masterPassword = "dupa45K#"

# Load the KeePass database
$database = New-Object KeePassLib.PwDatabase
$ioConnection = New-Object KeePassLib.Serialization.IOConnectionInfo
$ioConnection.Path = $databasePath

# Create a composite key (for master password)
$compositeKey = New-Object KeePassLib.Keys.CompositeKey
$masterKey = New-Object KeePassLib.Keys.KcpPassword
$masterKey.Password = $masterPassword
$compositeKey.AddUserKey($masterKey)

# Open the database
$database.Open($ioConnection, $compositeKey, $null)

# Retrieve entries
$entries = $database.RootGroup.GetEntries($true)

# Iterate through entries and display them
foreach ($entry in $entries) {
    $title = $entry.Strings.Get('Title').ReadString()
    $username = $entry.Strings.Get('UserName').ReadString()
    $password = $entry.Strings.Get('Password').ReadString()

    Write-Host "Title: $title"
    Write-Host "Username: $username"
    Write-Host "Password: $password"
    Write-Host ""
}

# Close the database
$database.Close()