# Store secured password 
#  $securePassword = ConvertTo-SecureString 'PASSWORD' -AsPlainText -Force
#  $securePassword | ConvertFrom-SecureString | Out-File 'S:\ABBOps\SchTasksSettings\SecurePassword.txt'

# Define the folder containing the scheduled tasks
$folder = "EPM Maestro"

# Define value for the "ExecutionTimeLimit" 
$timeLimit = "PT3H"
                
# Set credentials for the task
$user = "ABB\PL-XHFM-TSKSCH-STG"  # Replace with the correct domain and username

# Read the password from the secure file
$passwordFile = 'S:\ABBOps\SchTasksSettings\SecurePassword.txt'
$securePassword = Get-Content $passwordFile | ConvertTo-SecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))

try {
    # Get all scheduled tasks in the specified folder - excluded by name
    $tasks = Get-ScheduledTask -TaskPath "\$folder\" | Where-Object { $_.TaskName -notlike "*Yearly*" }

    # Check if any tasks were retrieved
    if ($tasks) {
        foreach ($task in $tasks) {
            try {
                # Get the task settings
                $settings = $task.Settings

                # Get the task name
                $taskName = $task.TaskName

                # Set the "ExecutionTimeLimit" parameter to defined value
                $settings.ExecutionTimeLimit = $timeLimit

                # Set the updated task settings
                Set-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Settings $settings -User $user -Password $password
            } catch {
                Write-Host "Failed to update task '$taskName'. Error: $_" -ForegroundColor Red
            }
        }

        # Output the tasks that were modified
        $tasks | Select-Object TaskName, TaskPath, @{Name="ExecutionTimeLimit";Expression={$_.Settings.ExecutionTimeLimit}}
    } else {
        Write-Host "No tasks to edit." -ForegroundColor Magenta
    }
} catch {
    Write-Host "An error occurred while retrieving or updating tasks. Error: $_" -ForegroundColor Red
}
