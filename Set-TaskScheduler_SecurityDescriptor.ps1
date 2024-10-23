#Get Security Descriptor
$TaskScheduler = New-Object -ComObject Schedule.Service
$TaskScheduler.Connect()
$Task = $TaskScheduler.GetFolder('\EPM Maestro').GetTask('130. Monthly Full Daily 11')
$SecurityDescriptor = $Task.GetSecurityDescriptor(0xF)
Write-Host "SecurityDescriptor:" -ForegroundColor Cyan
$SecurityDescriptor

(ConvertFrom-SddlString -Sddl $SecurityDescriptor).DiscretionaryAcl


#Set Security descriptor (example)
$TaskName = '120. Monthly Evening 11'
$tasks = Get-ScheduledTask -TaskPath "\EPM Maestro\" | Where-Object { $_.TaskName -notlike "*JCLF*" }
foreach ($task in $tasks)
{
$TaskName = $task.TaskName
$TaskPath = '\EPM Maestro'
$Scheduler = New-Object -ComObject "Schedule.Service"
$Scheduler.Connect()
$GetTask = $Scheduler.GetFolder($TaskPath).GetTask($TaskName)
$GetSecurityDescriptor = $GetTask.GetSecurityDescriptor(0xF)
if ($GetSecurityDescriptor -notmatch 'A;;0x1200a9;;;AU') {
    $GetSecurityDescriptor = 'O:BAG:S-1-5-21-2905325446-4054960910-2172852593-513D:(A;ID;0x1f019f;;;BA)(A;ID;0x1f019f;;;SY)(A;ID;FA;;;S-1-5-21-2905325446-4054960910-2172852593-560751)(A;;FR;;;S-1-5-21-2905325446-4054960910-2172852593-560751)(A;;GRGWGX;;;S-1-5-21-2905325446-4054960910-2172852593-242604)'
    $GetTask.SetSecurityDescriptor($GetSecurityDescriptor, 0)
}
}