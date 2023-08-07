    clear 
	
	$Server = [System.Net.Dns]::GetHostByName($env:computerName).HostName
	$DateNow = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

	Write-Host "###########################"
	whoami
	Write-Host $Server
	Write-Host $DateNow
	Write-Host "###########################"

    schtasks.exe /query /s $Server /V /FO CSV | ConvertFrom-Csv |  Where { $_.HostName -eq $Server -and $_.TaskName -notmatch "Microsoft" } |`
     Select-Object HostName,TaskName, "Next Run Time", Status, "Last Run Time", "Last Result", Author, "Scheduled Task State" | Format-Table -Wrap -AutoSize
	 
	 $Result = schtasks.exe /query /s $Server /V /FO CSV | ConvertFrom-Csv |  Where { $_.HostName -eq $Server -and $_.TaskName -notmatch "Microsoft" } |`
     Select-Object HostName,TaskName, "Next Run Time", Status, "Last Run Time", "Last Result", Author, "Scheduled Task State" | Export-Csv "C:\ABBOps\SCRIPTS\SOX\$server.csv"