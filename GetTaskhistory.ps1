$TaskName = '\TEST' 
$EventFilter = @{
    LogName = 'Microsoft-Windows-TaskScheduler/Operational'
    Id = 100
    StartTime = Get-Date "2020-10-05"
    EndTime = Get-Date "2020-10-07"
}
# PropertySelector for the Correlation id (the InstanceId) and task name
[string[]]$PropertyQueries = @(
    'Event/EventData/Data[@Name="InstanceId"]'
    'Event/EventData/Data[@Name="TaskName"]'
)
$PropertySelector = New-Object System.Diagnostics.Eventing.Reader.EventLogPropertySelector @(,$PropertyQueries)
$taskEvents = (Get-WinEvent -FilterHashtable $EventFilter) | Where-Object {$_.Message -like "* instance of the `"$TaskName`" task*"}
# Loop through the start events
$TaskInvocations = foreach($StartEvent in $taskEvents){
    # Grab the InstanceId and Task Name from the start event
    $InstanceId,$TaskName = $StartEvent.GetPropertyValues($PropertySelector)  
    # Create result task run information
    [pscustomobject]@{
        TaskName = $TaskName
        StartTime = $StartEvent.TimeCreated
        ActionStarted = ($(Get-WinEvent -FilterXPath "*[System[(EventID=200)] and EventData[Data[@Name=""TaskInstanceId""] and Data=""{$InstanceId}""]]" -LogName 'Microsoft-Windows-TaskScheduler/Operational').Message | Out-String).Trim()
        ActionCompleted = ($(Get-WinEvent -FilterXPath "*[System[(EventID=201)] and EventData[Data[@Name=""TaskInstanceId""] and Data=""{$InstanceId}""]]" -LogName 'Microsoft-Windows-TaskScheduler/Operational').Message | Out-String).Trim()
        EndTime = $(Get-WinEvent -FilterXPath "*[System[(EventID=102)] and EventData[Data[@Name=""InstanceId""] and Data=""{$InstanceId}""]]" -LogName 'Microsoft-Windows-TaskScheduler/Operational' -ErrorAction SilentlyContinue).TimeCreated
    }
}

Write-Host
Write-Host 'Result number of records: ' $taskEvents.Count
$TaskInvocations | Export-Csv -Path .\test.csv -NoTypeInformation
Write-Host ($TaskInvocations | Format-Table | Out-String)