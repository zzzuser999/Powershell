function CheckServiceState {
    param ($ServiceName = "PrintNotify"
    )
    try {
        if (get-service $ServiceName.Status -ne $true){
            Write-Host $ServiceName + " is not runing"
        }
        else {
            Write-Host $ServiceName + " is running"
        }
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
}
CheckServiceState