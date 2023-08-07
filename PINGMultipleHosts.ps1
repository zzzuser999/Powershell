$servers = get-content -Path "C:\Users\PLMAMRO7\Documents\ALL\serverlist_1.csv"

foreach ($server in $servers) {
    <# $server is the current item #>
    if (test-connection $server -count 1 -ErrorAction silentlycontinue) {
        <# Action to perform if the condition is true #>
        write-host "$server is UP"
        add-content -path "C:\Users\PLMAMRO7\Documents\ALL\serverstatus.log" -value "$server is UP"
    }
    else {
        <# Action when all if and elseif conditions are false #>
        write-host "$server is DOWN"
        add-content -path "C:\Users\PLMAMRO7\Documents\ALL\serverstatus.log" -value "$server is DOWN"
    }
}
