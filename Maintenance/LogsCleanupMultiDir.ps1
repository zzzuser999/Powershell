#######################################################
###          ADD NEW DIR to cleanup  A T  B O T T O M !

################## Cleanup function ###################
#----- define extension
$Extension = "*.*"
#----- get files based on lastwrite filter and specified folder
function ClearFolder([IO.DirectoryInfo] $Folder, $Days)
{
    $Counter = 0
	$Now = Get-Date 
	$LastWrite = $Now.AddDays(-$Days)

	$Files = Get-Childitem $Folder -Include $Extension -Recurse  | Where {$_.LastWriteTime -le "$LastWrite"} # 

	Write-Host ""
	Write-Host "|DIR: $Folder"
	Write-Host "|------------------------------------------------------------|"
	
	foreach ($File in $Files) 
	{
		if ($File -ne $NULL)
			{
				write-host "Deleting File $File | $LastWrite" -ForegroundColor "DarkRed"
				Remove-Item $File.FullName | out-null
				$Counter++
			}
		else
			{
				#Write-Host "No files to delete!" -foregroundcolor "Green"
			}
	}
	
	Write-Host "|------------------------------------------------------------|"
	Write-Host "|Removed: $Counter file(s)." -foregroundcolor "Green"
	
}



################## GO, GO ###################
#LOGS
ClearFolder "D:\EPMTools\Provisioning_old\logs" 30



