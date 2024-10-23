$tasks = Get-ScheduledTask -TaskPath "\MMR\"
foreach ($task in $tasks)
{
$TaskName = $task.TaskName
$TaskPath = '\MMR'
$Scheduler = New-Object -ComObject "Schedule.Service"
$Scheduler.Connect()
$GetTask = $Scheduler.GetFolder($TaskPath).GetTask($TaskName)
$GetSecurityDescriptor = $GetTask.GetSecurityDescriptor(0xF)
if ($GetSecurityDescriptor -notmatch 'A;;0x1200a9;;;AU') {
    $GetSecurityDescriptor = $GetSecurityDescriptor + '(A;;GRGX;;;AU)'
    $GetTask.SetSecurityDescriptor($GetSecurityDescriptor, 0)
    #$GetSecurityDescriptor
    (ConvertFrom-SddlString -Sddl $GetSecurityDescriptor).DiscretionaryAcl
}
}