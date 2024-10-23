Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | Select-Object `
    @{Name="DriveLetter";Expression={$_.DeviceID}},
    @{Name="FileSystem";Expression={$_.FileSystem}},
    @{Name="Size (GB)";Expression={[math]::round($_.Size / 1GB, 2)}},
    @{Name="FreeSpace (GB)";Expression={[math]::round($_.FreeSpace / 1GB, 2)}},
    @{Name="VolumeLabel";Expression={$_.VolumeName}},
    @{Name="FreeSpace (%)";Expression={[math]::round(($_.FreeSpace / $_.Size) * 100, 2)}} | FT