$paths = @("c:\VMs", "c:\temp", "c:\xyzzzz")
$computers = @("SRV1", "SRV2", "SRV3")

foreach ($path1 in $paths) {
    if (test-path $path1) {
        Write-Host "Folders in " $path1 -ForegroundColor green
        (Get-ChildItem -path $path1).count
    }
    else {
        Write-Host "`n`nPath "  $path1 " do not exists." -ForegroundColor cyan
    }

}

Write-Host -ForegroundColor yellow "test"