# Function to calculate and display total provisioned and used space
function Get-DiskSpace {
    param (
        [string]$ComputerName
    )

    # Get disk information using Get-CimInstance
    $volumes = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_LogicalDisk -Filter "DriveType=3"

    # Calculate total provisioned space
    $totalProvisionedSpace = ($volumes | Measure-Object -Property Size -Sum).Sum

    # Calculate total used space
    $totalUsedSpace = $volumes | ForEach-Object { $_.Size - $_.FreeSpace } | Measure-Object -Sum | Select-Object -ExpandProperty Sum

    # Convert spaces to GB
    $totalProvisionedSpaceGB = "{0:N2}" -f ($totalProvisionedSpace / 1GB)
    $totalUsedSpaceGB = "{0:N2}" -f ($totalUsedSpace / 1GB)

    # Display total provisioned and used space
    Write-Host $ComputerName -ForegroundColor Cyan
    Write-Output "Total Provisioned Space: $totalProvisionedSpaceGB GB"
    Write-Output "Total Used Space: $totalUsedSpaceGB GB"

    # Display individual volume information
    Write-Output "Volumes Information:"
    foreach ($volume in $volumes) {
        $volumeSizeGB = "{0:N2}" -f ($volume.Size / 1GB)
        #$volumeFreeSpaceGB = "{0:N2}" -f ($volume.FreeSpace / 1GB)
        $volumeUsedSpaceGB = "{0:N2}" -f (($volume.Size - $volume.FreeSpace) / 1GB)
        Write-Output "Volume: $($volume.DeviceID)"
        #Write-Output "  File System: $($volume.FileSystem)"
        Write-Output "  Size: $volumeSizeGB GB"
        #Write-Output "  Free Space: $volumeFreeSpaceGB GB"
        Write-Output "  Used Space: $volumeUsedSpaceGB GB"
        Write-Output ""
    }
}

# Run the function for the remote computer
#$serversEPM = @("XC-S-ZW09295.xc.abb.com","XC-S-ZW09281.xc.abb.com","XC-S-ZW09282.xc.abb.com","XC-S-ZW09310.xc.abb.com","XC-S-ZW09527.xc.abb.com","XC-S-ZW09312.xc.abb.com","XC-S-ZW09528.xc.abb.com")
#$serversAMD = @("XC-S-ZW09294.xc.abb.com","XC-S-ZW09049.xc.abb.com","XC-S-ZW09031.xc.abb.com")
$serversAMD = @("XC-S-ZW09301.xc.abb.com","XC-S-ZW09302.xc.abb.com","XC-S-ZW09303.xc.abb.com","XC-S-ZW09304.xc.abb.com")
foreach ($server in $serversAMD) {
    Get-DiskSpace -ComputerName $server
}
#Get-DiskSpace -ComputerName $env:COMPUTERNAME