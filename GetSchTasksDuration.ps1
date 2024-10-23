# Define the task folder
$taskFolderPath = "\MMR\"

# Set output CSV file
$outputCsvPath = "c:\tmp\tasksDuration.csv"

# Get all tasks in the specified folder
$tasks = Get-ScheduledTask -TaskPath $taskFolderPath

# Initialize an array to store task execution statistics
$taskDurations = @()

# Loop through each scheduled task and get its execution durations
foreach ($task in $tasks) {
    $taskName1 = $task.TaskName
    $taskName = $taskFolderPath + $taskName1
    $taskPath = $task.TaskPath
    Write-Host "Retriving data for: " $taskName -ForegroundColor green

    # Get task history events from the event log
    $taskEvents = Get-WinEvent -LogName Microsoft-Windows-TaskScheduler/Operational `
                               | Where-Object { $_.Properties[0].Value -eq $taskName } `
                               | Select-Object TimeCreated, Id, Message

    # Filter start and end events
    $startEvents = $taskEvents | Where-Object { $_.Id -eq 100 }  # Task started
    $endEvents = $taskEvents | Where-Object { $_.Id -eq 102 -or $_.Id -eq 201 }  # Task completed

    # Calculate the duration for each run
    foreach ($startEvent in $startEvents) {
        $endEvent = $endEvents | Where-Object { $_.TimeCreated -gt $startEvent.TimeCreated } | Select-Object -First 1

        if ($endEvent) {
            $duration = $endEvent.TimeCreated - $startEvent.TimeCreated
            $taskDurations += [PSCustomObject]@{
                TaskName    = $taskName
                StartTime   = $startEvent.TimeCreated
                EndTime     = $endEvent.TimeCreated
                Duration    = $duration.TotalSeconds
            }
        }
    }

}

<## Calculate the average duration for each task
$averageDurations = $taskDurations | Group-Object TaskName | ForEach-Object {
    $taskName = $_.Name
    $averageDuration = ($_.Group | Measure-Object Duration -Average).Average
    [PSCustomObject]@{
        TaskName       = $taskName
        AverageDuration = [TimeSpan]::FromSeconds($averageDuration.TotalSeconds)
    }
}#>

# Calculate the average duration for each task
$averageDurations = $taskDurations | Group-Object TaskName | ForEach-Object {
    $taskName = $_.Name
    $averageDuration = ($_.Group | Measure-Object -Property Duration -Average).Average
    $maxDuration = ($_.Group | Measure-Object -Property Duration -Maximum).Maximum
    $minDuration = ($_.Group | Measure-Object -Property Duration -Minimum).Minimum
    [PSCustomObject]@{
        TaskName       = $taskName
        AverageDuration = [TimeSpan]::FromSeconds([double]$averageDuration)
        MaxDuration = [TimeSpan]::FromSeconds([double]$maxDuration)
        MinDuration = [TimeSpan]::FromSeconds([double]$minDuration)
    }
}

# Export the task durations to a CSV file
$taskDurations | Export-Csv -Path $outputCsvPath -NoTypeInformation

# Output the task durations
$taskDurations | Format-Table -AutoSize
$averageDurations | Format-Table -AutoSize
