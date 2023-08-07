$servers = Get-Content .\servers.txt

foreach ($server in $servers) {
	try {
		$null = Test-Connection -ComputerName $server -Count 1 -ErrorAction STOP
		Write-Host $server -ForegroundColor green
Invoke-command -computerName $server -scriptblock {gwmi win32_logicaldisk | select DeviceId, VolumeName, MediaType, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}},@{n="% Free";e={[math]::Round(($_.freeSpace) / ($_.Size) * 100,0)}} | where MediaType -eq '12' | ft deviceid,VolumeName,Size,FreeSpace,'% Free' -AutoSize}
	}
	catch {
		Write-Output "$server - $($_.Exception.Message)"
	}
}

#Write-Host $env:computername -ForegroundColor green
#gwmi win32_logicaldisk | select DeviceId, VolumeName, MediaType, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}},@{n="% Free";e={[math]::Round(($_.freeSpace) / ($_.Size) * 100,0)}} | where MediaType -eq '12' | ft deviceid,VolumeName,Size,FreeSpace,'% Free' -AutoSize
#gwmi win32_logicaldisk | select DeviceId, VolumeName, MediaType, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}},@{n="% Free";e={[math]::Round(($_.freeSpace) / ($_.Size) * 100,0)}} | where MediaType -eq '12'