function Get-QUserInfo
    {
    [CmdletBinding()]
    Param (
        [Parameter ()]
            [string[]]
            $ComputerName = $env:COMPUTERNAME
        )

    begin
        {
        $Header = 'UserName','SessionName','ID','State','IdleTime','LogonTime'
        $No_Connection = '-- No Connection --'
        }

    process
        {
        foreach ($CN_Item in $ComputerName)
            {
            if (Test-Connection -ComputerName $CN_Item -Count 1 -Quiet)
                {
               <# quser /server:$CN_Item |
                    Select-Object -Skip 1 |
                    ForEach-Object {($_ -replace '\s{2,}', ',').Trim()} |
                    ConvertFrom-Csv -Header $Header |
				#>
				(((quser) -replace '^>', '') -replace '\s{2,}', ',').Trim() | select-object -skip 1 | ForEach-Object {
    if ($_.Split(',').Count -eq 5) {
        Write-Output ($_ -replace '(^[^,]+)', '$1,')
    } else {
        Write-Output $_
    }
} | ConvertFrom-Csv -header $header |
                    ForEach-Object {
                        if ($_.IdleTime -eq '.')
                            {
                            $IdleTime = "Active"
                            }
                            else
                            {
							$IdleTime = $_.IdleTime
                            #logoff $_.ID
                            }


                        [PSCustomObject]@{
                            ComputerName = $CN_Item
                            UserName = $_.UserName
                            SessionName = $_.SessionName
                            ID = $_.ID
                            State = $_.State
                            IdleTime = $IdleTime
                            LogonTime = [datetime]$_.LogonTime
                            }
                        }                
                }
                else
                {
                [PSCustomObject]@{
                    ComputerName = $CN_Item
                    UserName = $No_Connection
                    SessionName = $No_Connection
                    ID = $No_Connection
                    State = $No_Connection
                    IdleTime = $No_Connection
                    LogonTime = $No_Connection
                    }                
                }
            } # end >> foreach ($CN_Item in $ComputerName)
        } # end >> process {}

    end {}

    } # end >> function Get-QUserInfo



Get-QUserInfo -ComputerName LocalHost