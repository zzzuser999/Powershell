$maxLoginDate =  Get-Date -Date "1970-01-01 00:00:00Z"

    #Configure log filters
    $ns = @{'ns'='http://schemas.microsoft.com/win/2004/08/events/event'}
    $target_xpath = "//ns:Data[@Name='TargetUserName']"
    $usersid_xpath = "//ns:Data[@Name='UserSid']"
    $events = @()
    $events += Get-WinEvent -ErrorAction SilentlyContinue  -FilterHashtable  @{ 
        LogName='Security'
        Id=@(4800,4801)
        StartTime= $maxLoginDate 
    }
    $events += Get-WinEvent -ErrorAction SilentlyContinue  -FilterHashtable  @{ 
        LogName='System'
        Id=@(7001,7002)
        StartTime= $maxLoginDate
    }
    $type_lu = @{
        7001 = 'Logon'
        7002 = 'Logoff'
        4800 = 'Lock'
        4801 = 'UnLock'
    }
        $loginHistory = ForEach($event in $events) {
            $xml = $event.ToXml()
            Switch -Regex ($event.Id) {
                '4...' {
                    $user = (
                        Select-Xml -Content $xml -Namespace $ns -XPath $target_xpath
                    ).Node.'#text'
                    Break            
                }
                '7...' {
                    $sid = (
                        Select-Xml -Content $xml -Namespace $ns -XPath $usersid_xpath
                    ).Node.'#text'
                    if(!$sid) { continue }
                    try {
                        $user = (
                        New-Object -TypeName 'System.Security.Principal.SecurityIdentifier' -ArgumentList $sid
                    ).Translate([System.Security.Principal.NTAccount]).Value
              
                    } catch {
                       $user = $sid
                    }
                    
                    Break
                }
            }
            
            New-Object -TypeName PSObject -Property @{
                Time = $event.TimeCreated
                Id = $event.Id
                Action = $type_lu[$event.Id]
                User = $user
            }
        
        }
         
        Write-Host  ($loginHistory | Where-Object {$_.User -eq 'europe\plmamro7'} | Format-Table | Out-String)