function MapDrive {
    <#param (
        # Parameter help description
        [Parameter()]
        [string]
        $UserName
    ) #>
    $var_currrentuser = $env:USERNAME
    Write-Host $var_currrentuser

    if ($var_currrentuser -in ("xxx*", "PLMAMRO7")) {
        New-PSDrive -Name "U" -PSProvider FileSystem -Root \\localhost\ShareTest$ -Scope Global -Persist
        Write-Host "Drive Mapped" -ForegroundColor Green
    }
    else {
        Write-Host "Wrong User" -ForegroundColor Red
    }
}

MapDrive