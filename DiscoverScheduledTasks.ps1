# Script: DiscoverSchelduledTasks
# Author: Romain Si
# Revision: Isaac de Moraes
# This script is intended for use with Zabbix > 3.x
#
#
# Add to Zabbix Agent
#   UserParameter=TaskSchedulerMonitoring[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent\DiscoverScheduledTasks.ps1" "$1" "$2"
#
## Modifier la variable $path pour indiquer les sous dossiers de T�ches Planifi�es � traiter sous la forme "\nomDossier\","\nomdossier2\sousdossier\" voir (Get-ScheduledTask -TaskPath )
## Change the $path variable to indicate the Scheduled Tasks subfolder to be processed as "\nameFolder\","\nameFolder2\subfolder\" see (Get-ScheduledTask -TaskPath )




Function Convert-ToUnixDate ($PSdate) {
   $epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970')
   (New-TimeSpan -Start $epoch -End $PSdate).TotalSeconds
}

$ITEM = [string]$args[0]
$ID = [string]$args[1]

switch ($ITEM) {
  "DiscoverTasks" {
$apptasks = Get-ScheduledTask  | where {$_.TaskPath -notmatch "Microsoft"}
$apptasksok1 = $apptasks.TaskName
$apptasksok = $apptasksok1.replace('�','&acirc;').replace('�','&agrave;').replace('�','&ccedil;').replace('�','&eacute;').replace('�','&egrave;').replace('�','&ecirc;')
$idx = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($currentapptasks in $apptasksok)
{
    if ($idx -lt $apptasksok.count)
    {
     
        $line= "{ `"{#APPTASKS}`" : `"" + $currentapptasks + "`" },"
        write-host $line
    }
    elseif ($idx -ge $apptasksok.count)
    {
    $line= "{ `"{#APPTASKS}`" : `"" + $currentapptasks + "`" }"
    write-host $line
    }
    $idx++;
} 
write-host
write-host " ]"
write-host "}"}}


switch ($ITEM) {
  "TaskLastResult" {
[string] $name = $ID
$name1 = $name.replace('&acirc;','�').replace('&agrave;','�').replace('&ccedil;','�').replace('&eacute;','�').replace('&egrave;','�').replace('&ecirc;','�')
$pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name1"
$pathtask1 = $pathtask.Taskpath
$taskResult = Get-ScheduledTaskInfo -TaskPath "$pathtask1" -TaskName "$name1"
Write-Output ($taskResult.LastTaskResult)
}}

switch ($ITEM) {
  "TaskLastRunTime" {
[string] $name = $ID
$name1 = $name.replace('&acirc;','�').replace('&agrave;','�').replace('&ccedil;','�').replace('&eacute;','�').replace('&egrave;','�').replace('&ecirc;','�')
$pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name1"
$pathtask1 = $pathtask.Taskpath
$taskResult = Get-ScheduledTaskInfo -TaskPath "$pathtask1" -TaskName "$name1"
$taskResult1 = $taskResult.LastRunTime
$date = get-date -date "01/01/1970"
$taskResult2 = Convert-ToUnixDate($taskResult1)
Write-Output ($taskResult2)
}}

switch ($ITEM) {
  "TaskNextRunTime" {
[string] $name = $ID
$name1 = $name.replace('&acirc;','�').replace('&agrave;','�').replace('&ccedil;','�').replace('&eacute;','�').replace('&egrave;','�').replace('&ecirc;','�')
$pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name1"
$pathtask1 = $pathtask.Taskpath
$taskResult = Get-ScheduledTaskInfo -TaskPath "$pathtask1" -TaskName "$name1"
$taskResult1 = $taskResult.NextRunTime
$date = get-date -date "01/01/1970"
$taskResult2 = Convert-ToUnixDate($taskResult1)
Write-Output ($taskResult2)
}}

switch ($ITEM) {
  "TaskState" {
[string] $name = $ID
$name1 = $name.replace('&acirc;','�').replace('&agrave;','�').replace('&ccedil;','�').replace('&eacute;','�').replace('&egrave;','�').replace('&ecirc;','�')
$pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name1"
$pathtask1 = $pathtask.State
Write-Output ($pathtask1)
}}