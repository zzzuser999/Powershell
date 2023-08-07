#Version 0.1
$query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">
	*[System[(EventID=4624)]] and
    *[System[TimeCreated[@SystemTime&gt;='2022-11-03T23:00:00.000Z' and @SystemTime&lt;='2022-11-04T23:00:00.999Z']]]
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

$events = Get-WinEvent -FilterXml $query

# Loop through the start events
$EventDetails = foreach($StartEvent in $events){
    # Grab the InstanceId and Task Name from the start event
    $SubjectUserName, $SubjectDomainName, $TargetUserName, $TargetDomainName, $TargetLogonId = $StartEvent.GetPropertyValues($PropertySelector)  
    $targetLogonHex = '0x' + [System.Convert]::ToString($TargetLogonId,16);
    
    $actionEvents = Get-WinEvent -FilterXPath "*[System[(EventID=4688)]] and *[EventData[Data[@Name='SubjectLogonId'] and Data='$targetLogonHex']]" -LogName Security
    $actions = $actionEvents | ForEach-Object{ 
        $_.GetPropertyValues($ActionPropertySelector)
    }

    [pscustomobject]@{
        TimeCreated = $StartEvent.TimeCreated
        SubjectUserName = $SubjectUserName
        SubjectDomainName = $SubjectDomainName
        TargetUserName = $TargetUserName
        TargetDomainName = $TargetDomainName
        TargetLogonId = $targetLogonHex
        Actions = $actions -join ";"
        #ActionsTable = $actions
        #Xml = $StartEvent.ToXml()       
    }
}

Write-Host 'Result number of records: ' $EventDetails.Count
#$EventDetails | Export-Csv -Path .\test.csv -notype -force
Write-Host ($EventDetails | Format-List | Out-String)
