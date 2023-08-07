Import-Module activedirectory

#$tabAccountsManagerEurope = Import-Csv -Path "C:\Users\PLMAMRO7\Documents\Scripts\ServiceAccounts\ABB-ServiceAccountsEurope-202102.csv"
$tabAccountsManagerABB = Import-Csv -Path "C:\Users\PLMAMRO7\Documents\Scripts\ServiceAccounts\ABB-ServiceAccountsEurope-20210317.csv"


<#foreach ($objItem in $tabAccountsManagerEurope)
{
    get-aduser $objItem.manager | get-aduser -Properties * | select mail | Export-Csv ServiceAccounts\ABB-ServiceAccountsManagerEurope-202102.csv -Append
} #>

foreach ($objItem in $tabAccountsManagerABB)
{
    get-aduser $objItem.manager | get-aduser -Properties * | select mail | Export-Csv ServiceAccounts\ABB-ServiceAccountsManagerEurope-20210317.csv -Append
    Write-Host $objItem.manager
}