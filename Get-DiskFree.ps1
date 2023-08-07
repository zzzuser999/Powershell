function DiskFree {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('cn')]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [Parameter(Position=1, Mandatory=$false)]
        [Alias('cr')]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Position=2)]
        [Alias('f')]
        [switch]$Format
    )

    begin {
        $ErrorActionPreference = "Stop"

        function Format-HumanReadable {
            param (
                $size
            )

            switch ($size) {
                {$_ -ge 1PB}
                    {"{0:#.#'P'}" -f ($size / 1PB); break}
                {$_ -ge 1TB}
                    {"{0:#.#'T'}" -f ($size / 1TB); break}
                {$_ -ge 1GB}
                    {"{0:#.#'G'}" -f ($size / 1GB); break}
                {$_ -ge 1MB}
                    {"{0:#.#'M'}" -f ($size / 1MB); break}
                {$_ -ge 1KB}
                    {"{0:#'K'}" -f ($size / 1KB); break}
                default 
                    {"{0}" -f ($size) + "B"}
            }
        }

        $wmiq = 'SELECT * FROM Win32_LogicalDisk WHERE Size != Null AND DriveType >= 2'
    }

    process {
        foreach ($computer in $ComputerName) {
            try {
                if ($computer -eq $env:COMPUTERNAME) {
                    $disks = Get-CimInstance -Query $wmiq -ComputerName $computer
                }
                else {
                    $disks = Invoke-Command -ArgumentList $wmiq { param($wmiq) Get-CimInstance -Query $wmiq } -ComputerName $computer -Credential $Credential `
                        | Select-Object DeviceID, DriveType, ProviderName, FreeSpace, Size, VolumeName
                }

                if ($Format) {
                    # Create array for $disk objects and then populate
                    $diskarray = @()
                    $disks | ForEach-Object { $diskarray += $_ }

                    $diskarray | Select-Object
                        @{Name='Name'; Expression={$_.SystemName}},
                        @{Name='Vol'; Expression={$_.DeviceID}},
                        @{Name='Size'; Expression={Format-HumanReadable $_.Size}},
                        @{Name='Used'; Expression={Format-HumanReadable (($_.Size)-($_.FreeSpace))}},
                        @{Name='Avail'; Expression={Format-HumanReadable $_.FreeSpace}},
                        @{Name='Use%'; Expression={[int](((($_.Size)-($_.FreeSpace))/($_.Size) * 100))}},
                        @{Name='FS'; Expression={$_.FileSystem}},
                        @{Name='Type'; Expression={$_.Description}}
                }
                else {
                    foreach ($disk in $disks) {
                        $diskprops = @{
                            'Volume'=$disk.DeviceID;
                            'Size'=$disk.Size;
                            'Used'=($disk.Size - $disk.FreeSpace);
                            'Available'=$disk.FreeSpace;
                            'FileSystem'=$disk.FileSystem;
                            'Type'=$disk.Description
                            'Computer'=$disk.SystemName;
                        }

                        # Create custom PS object and apply type
                        $diskobj = New-Object -TypeName PSObject -Property $diskprops
                        $diskobj.PSObject.TypeNames.Insert(0,'BinaryNature.DiskFree')

                        Write-Output $diskobj
                    }
                }
            }
            catch {
                # Check for common DCOM errors and display "friendly" output
                switch ($_) {
                    { $_.Exception.ErrorCode -eq 0x800706ba }
                        {$err = 'Unavailable (Host Offline or Firewall)'; break}
                    { $_.CategoryInfo.Reason -eq 'UnauthorizedAccessException' }
                        {$err = 'Access denied (Check User Permissions)'; break}
                    default
                        {$err = $_.Exception.Message}
                }
                Write-Warning "$computer - $err"
            }
        }
    }

    end {

    }
}


DiskFree | ft