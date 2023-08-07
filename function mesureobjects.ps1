function mesureobject {
    param (
        [array]$paths
        
    )
    foreach ($path in $paths) {
        Get-ChildItem -Path $path -Recurse -File | Measure-Object -Property Length -Sum
    }
}

mesureobject "c:\temp", "c:\users\plmamro7\pictures"