#Declare Array
$triggers = @()

#Set Variables for 
$ReferenceTask = Read-Host -Prompt "Reference Task"
$DestinationTask = Read-Host -Prompt "Destination Task"
$TaskName = (Get-ScheduledTask -TaskName $DestinationTask).TaskName
$TaskPath = (Get-ScheduledTask -TaskName $DestinationTask).TaskPath

#Get Triggers
$triggers = (Get-ScheduledTask -TaskName $ReferenceTask ).triggers

#Set Triggers
Set-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -Trigger $triggers #-Verbose

#Display settings
Write-Host "`nTriggers for task " $TaskName " are now: " -ForegroundColor Green
(Get-ScheduledTask -TaskName $TaskName).Triggers
