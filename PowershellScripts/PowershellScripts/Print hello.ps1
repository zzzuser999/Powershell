Clear

$user = whoami
$userName = $user.Substring(4)
Write-Host "PS C:\Users\$userName> " -NoNewline
Write-Host "whoami" -f Yellow
Write-Host -NoNewline
$user
Write-Host "PS C:\Users\$userName> " -NoNewLine
Write-Host "get-date " -NoNewLine -f Yellow
Write-Host "-format " -NoNewLine -f DarkGray
Write-Host `''u'`' -f DarkCyan
Get-Date -format 'u'
Write-Host "PS C:\Users\$userName> " -NoNewline
Write-Host "hostname" -f Yellow
Write-Host -NoNewline
hostname