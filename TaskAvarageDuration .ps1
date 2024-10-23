$averageDurations = $taskDurations | Group-Object TaskName | ForEach-Object {
    $taskName = $_.Name
    $averageDuration = ($_.Group | Measure-Object -Property Duration -Average).Average
    $maxDuration = ($_.Group | Measure-Object -Property Duration -Maximum).Maximum
    $minDuration = ($_.Group | Measure-Object -Property Duration -Minimum).Minimum
    [PSCustomObject]@{
        TaskName       = $taskName
        AverageDuration = [TimeSpan]::FromSeconds([double]$averageDuration.TotalSeconds)
        MaxDuration = [TimeSpan]::FromSeconds([double]$maxDuration.TotalSeconds)
        MinDuration = [TimeSpan]::FromSeconds([double]$minDuration.TotalSeconds)
    }
}