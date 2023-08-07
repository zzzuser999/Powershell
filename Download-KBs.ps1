$KBs = (Import-Csv -Path .\Updates.csv).KB

New-Item -Path "C:\Users\plmamro7\Documents\LMT" -Name KBs20210324 -ItemType "directory"
foreach ($KB in $KBs) {
    Write-Host "Importing: " $KB -ForegroundColor Green
    Save-KbUpdate -Name $KB -Architecture x64 -Path "C:\Users\plmamro7\Documents\LMT\KBs20210324"
    
}