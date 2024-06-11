Param($procname)
set-variable timespan -value 1 -option constant

			$Count = Get-Process $procname -ea SilentlyContinue | Measure-Object -Line | Format-Wide Lines | Out-String
			$Count = $Count.Trim()

			If ($Count -gt 1)
			{
				Write-host CR: More than one process: $procname !
				exit 2
			}
			ElseIf ($Count -lt 1)
			{
				Write-host CR: No process: $procname !
				exit 2
			}
			Else
			{
			$getws = Get-Process $procname | Format-Wide WorkingSet64 | Out-String
			$ws =  $getws.trim() 
			$ws = $ws/1024
			$wsformated = "{0:N0}" -f $ws
				
				$starttime = (get-date)
				$getcpu1 = Get-Process $procname | Format-Wide CPU | Out-String
				$getcpu1 = $getcpu1.trim()
				$getcpu1 = [System.Decimal]::Parse($getcpu1) 
				
				sleep $timespan

				$getcpu2 = Get-Process $procname | Format-Wide CPU | Out-String
				$endtime = (get-date)
				$getcpu2 = $getcpu2.trim()
				$getcpu2 = [System.Decimal]::Parse($getcpu2) 
				$CpuDiff = $getcpu2 - $getcpu1

				$CpuDiff = $getcpu2 - $getcpu1

				$cpu = "{0:N4}" -f $CpuDiff/1 * 10
				
				$getstarttime = Get-Process $procname | Format-Wide StartTime | Out-String
				$getstarttime = $getstarttime.trim()
				$unit="KB"
			
				Write-host OK: CPU Usage: $cpu % - Working Set: $wsformated K. Runs from $getstarttime"|" CPU=$cpu% WS=$ws$unit
			
			exit 0
			}
