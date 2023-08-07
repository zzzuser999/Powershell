# Check RunAs Actions 22.03.2021
#
# To execute from within NSClient++
#
# [NRPE Handlers]
# check_runas_actions = cmd /c echo scripts/CheckRunAsActions.ps1 -ForLastDays 10; exit($lastexitcode) | powershell.exe -command -


[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [int]$ForLastDays
)

#ExitCode:  0 = OK, 1 = WARNING, 2 = CRITICAL, 3 = UNKNOWN
$NotOlderThan = ((Get-Date).AddDays(-$ForLastDays)) | Get-Date -Format o

$EventLogQuery = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">
	  *[System[(EventID=4624)]] and
    *[System[TimeCreated[@SystemTime&gt;='$NotOlderThan']]]
    </Select>
    <Suppress Path="Security">
    *[EventData[Data[@Name='SubjectUserSid'] and Data = "S-1-0-0"]] or
    *[EventData[Data[@Name='SubjectUserSid'] and Data = "S-1-5-18"]]
    </Suppress>
  </Query>
</QueryList>
"@

# PropertySelector for the Correlation id (the InstanceId) and task name
[string[]]$PropertyQueries = @(
  'Event/EventData/Data[@Name="SubjectUserName"]'
  'Event/EventData/Data[@Name="SubjectDomainName"]'
  'Event/EventData/Data[@Name="TargetUserName"]'
  'Event/EventData/Data[@Name="TargetDomainName"]'
  'Event/EventData/Data[@Name="TargetLogonId"]'
)
[string[]]$ActionPropertyQueries = @(
  'Event/EventData/Data[@Name="CommandLine"]'
)

$PropertySelector = New-Object System.Diagnostics.Eventing.Reader.EventLogPropertySelector @(,$PropertyQueries)
$ActionPropertySelector = New-Object System.Diagnostics.Eventing.Reader.EventLogPropertySelector @(,$ActionPropertyQueries)


$Events = Get-WinEvent -FilterXml $EventLogQuery -ErrorAction SilentlyContinue

if ($Events.Count -eq 0) {
  Write-Host "OK: No 'Run As...' actions from $NotOlderThan to $(Get-Date -Format o) [ForLastDays=$ForLastDays]." 
  exit 0
}
else {
  # Loop through the start events
  $EventDetails = foreach ($StartEvent in $events) {
    # Grab the InstanceId and Task Name from the start event
    $SubjectUserName, $SubjectDomainName, $TargetUserName, $TargetDomainName, $TargetLogonId = $StartEvent.GetPropertyValues($PropertySelector)  
    $targetLogonHex = '0x' + [System.Convert]::ToString($TargetLogonId, 16);
      
    $actionEvents = Get-WinEvent -FilterXPath "*[System[(EventID=4688)]] and *[EventData[Data[@Name='SubjectLogonId'] and Data='$targetLogonHex']]" -LogName Security -ErrorAction SilentlyContinue
    $actions = $actionEvents | ForEach-Object { 
      $_.GetPropertyValues($ActionPropertySelector)
    }

    [pscustomobject]@{
      LoginTime       = $StartEvent.TimeCreated
      SubjectUserName   = $SubjectUserName
      SubjectDomainName = $SubjectDomainName
      TargetUserName    = $TargetUserName
      TargetDomainName  = $TargetDomainName
      TargetLogonId     = $targetLogonHex
      Actions           = $actions -join ";"  
    }
  }
  Write-Host  "WARNING: There were $($Events.Count) 'Run As...' actions executed from $NotOlderThan to $(Get-Date -Format o) [ForLastDays=$ForLastDays]. |" 
  Write-Host ($EventDetails | Format-List | Out-String)
  exit 1
}