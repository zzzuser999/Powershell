Import-Module activedirectory

#$strDate = get-date -Format "yyyyMMdd"
$tabAccountsEurope = Import-Csv -Path "C:\Users\PLMAMRO7\Documents\Scripts\ABB-ServiceAccounts-Europe-20210216.csv"
$tabAccountsABB = Import-Csv -Path "C:\Users\PLMAMRO7\Documents\Scripts\ABB-ServiceAccounts-ABB-20210216.csv"

foreach ($objItem in $tabAccountsEurope)
{
    get-aduser $objItem.sName -properties * -server europe.abb.com | select name,UserPrincipalName,DistinguishedName,manager,info,description | Export-Csv ServiceAccounts\ABB-ServiceAccountsEurope-20210317.csv -Append
}
 Write-host "Data for europe extracted... " -ForegroundColor Cyan 
 
foreach ($objItem in $tabAccountsABB)
{
#get-aduser $objItem.sName -properties * -server abb.com | select name,UserPrincipalName,DistinguishedName,manager | Export-Csv ServiceAccounts\ABB-ServiceAccountsABB-202102.csv -Append
get-aduser $objItem.sName -properties * -server abb.com | select name,info,description | Export-Csv ServiceAccounts\ABB-ServiceAccountsABBinfo-202100317.csv -Append
}
Write-host "Data for ABB extracted... " -ForegroundColor Cyan

#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
