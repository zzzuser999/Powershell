$Currentdate= (Get-Date).AddMonths(0).ToString("MMyyyy")
Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty |
Sort-Object -Property DisplayName | Select-Object -Property @{Name="Server_Name";Expression={$env:computername}}, InstallDate, @{Name="User ID";Expression={'N/A'}}, DisplayName, DisplayVersion |
Where-Object {($_.DisplayName -like "Hotfix*SQL*") -or ($_.DisplayName -like "Service Pack*SQL*")}|
Export-Csv -encoding UTF8 -NoTypeInformation -Path .\"DB_SQL_"$env:computername"_SOURCE_$Currentdate.csv"