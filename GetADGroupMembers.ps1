Function Get-ADGroupMemberFix {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string[]]
        $Identity,

        [string]
        $Server
    )

    begin {
        $additionalArguments = @{}
        if($PSBoundParameters.ContainsKey('Server')){
            $additionalArguments['Server'] = $Server
        }
    }

    process {
        foreach ($GroupIdentity in $Identity) {
            $Group = $null
            $Group = Get-ADGroup -Identity $GroupIdentity -Properties Member @additionalArguments -Server ABB
            if (-not $Group) {
                continue
            }
            Foreach ($Member in $Group.Member) {
                Get-ADObject $Member -Server EUROPE | select name
            }
        }
    }
}

Get-ADGroupMemberFix -Identity '!GLB_DebugPrograms_UserRights'