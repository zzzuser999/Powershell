<<<<<<< HEAD
function mesureobject {
    param (
        [array]$paths
        
    )
    foreach ($path in $paths) {
        Get-ChildItem -Path $path -Recurse -File | Measure-Object -Property Length -Sum
    }
}

=======
function mesureobject {
    param (
        [array]$paths
        
    )
    foreach ($path in $paths) {
        Get-ChildItem -Path $path -Recurse -File | Measure-Object -Property Length -Sum
    }
}

>>>>>>> origin/main
mesureobject "c:\temp", "c:\users\plmamro7\pictures"