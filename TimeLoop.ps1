# Start time
$startTime = Get-Date

# Duration to run the loop (1 minute)
$duration = [TimeSpan]::FromMinutes(5)

# Loop until the duration has elapsed
while ((Get-Date) - $startTime -lt $duration) {
    # Perform some operation inside the loop
    # For demonstration, we just sleep for 1 second in each iteration
    Start-Sleep -Seconds 1

    # Optional: Output the elapsed time
    $elapsed = (Get-Date) - $startTime
    Write-Host "Elapsed time: $($elapsed.TotalSeconds) seconds"
}

Write-Host "Loop has ended after 1 minute."
