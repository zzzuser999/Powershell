$thresholdMinutes = 90  # Set your threshold in minutes
$longRunningTasks = @()

# Get all scheduled tasks
$tasks = Get-ScheduledTask  | Where-Object { $_.State -eq 'Running' }

foreach ($task in $tasks) {
    $taskName = $task.TaskName
    $taskPath = $task.TaskPath

    # Get the task's last run time
    $taskLastRunTime = Get-ScheduledTaskInfo -TaskName $taskName -TaskPath $taskPath | Select-Object -ExpandProperty LastRunTime

    if ($taskLastRunTime) {
        $duration = (Get-Date) - $taskLastRunTime
        if ($duration.TotalMinutes -gt $thresholdMinutes) {
            $longRunningTasks += [PSCustomObject]@{
                TaskName = $taskName
                Duration = $duration
            }
        }
    }
}

<#if ($longRunningTasks.Count -gt 0) {
    Write-Host "Long-running tasks detected:"
    $longRunningTasks | Format-Table -AutoSize
} else {
    Write-Host "No long-running tasks detected."
}#>
$longRunningTasks | Format-Table -AutoSize