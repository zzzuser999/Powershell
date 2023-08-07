#Define time range - recommended monthly range
$Begin = Get-Date -Date '07/01/2021 00:00:00'
$End = Get-Date -Date '07/10/2021 23:59:59'
#Define location of report
$path = "C:\temp"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
#Check latest event from application log and compare with $Begin
$a = Get-WinEvent -LogName Application -MaxEvents 1 –Oldest | select TimeCreated
if ($begin -lt $a.TimeCreated.Date){
Get-EventLog -LogName Application -Source MsiInstaller -After $Begin -Before $End | select TimeGenerated, UserName, Message | sort TimeGenerated -Descending | Out-File -LiteralPath $path\software_actions_log_$(get-date -f yyyy-MM-dd).txt
Write-Host "Sorry but installation log doesn't containt all data for this data range. Please define new BeginDate."}
#To change application log size (for future use) please use below command
#$server_name = hostname
#reg add \\$server_name\HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\Application /t REG_DWORD /v MaxSize /d 4194304000 /f
Get-EventLog -LogName Application -Source MsiInstaller -After $Begin -Before $End | select TimeGenerated, UserName, Message | sort TimeGenerated -Descending | Out-File -LiteralPath $path\software_actions_log_$(get-date -f yyyy-MM-dd).txt
#Updates level 
$Session = New-Object -ComObject "Microsoft.Update.Session"
$Searcher = $Session.CreateUpdateSearcher()
$historyCount = $Searcher.GetTotalHistoryCount()
$Searcher.QueryHistory(0, $historyCount) | where {$_.Title -ne $NULL } | Select-Object Title, Date, @{name="Operation"; expression={switch($_.operation){1 {"Installation"}; 2 {"Uninstallation"}; 3 {"Other"}}}} | sort Date -Descending | Out-File -LiteralPath $path\updates_level_log_$(get-date -f yyyy-MM-dd).txt
#Current software
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction Ignore | Where-Object DisplayName | Select-Object -Property DisplayName, DisplayVersion, InstallDate | Sort-Object -Property InstallDate  -Descending | Out-File -LiteralPath $path\current_software_log_$(get-date -f yyyy-MM-dd).txt