#===================================
#===== SETTINGS
#===================================
$ArchiveDir =  "Y:\LogArchive\"
$KeepTheArchivesFor = 500 #days
#===================================
function ClearFolder($LogFolderPath, $fileDays)
{
    $logFiles = Get-ChildItem $LogFolderPath -Filter *.* | Where LastWriteTime -lt  (Get-Date).AddDays(-1 * $fileDays)

    Write-Host "Clearing... "
    Write-Host "=================================="

    foreach($file in $logFiles)
    {
        Write-Host $file.FullName -F DarkRed
        Remove-Item $file.FullName
    }
}

function ArchiveFolder ($ArchiveName, $LogFolderPath, $fileDays)
{
    $date = Get-Date -format "yyyy-MM-dd_HH-mm-ss"
    $ArchiveFileName = $ArchiveName+$date+".zip"
    $BackupZip = Join-Path $ArchiveDir $ArchiveFileName

    $logFiles = Get-ChildItem $LogFolderPath -Filter *.* | Where LastWriteTime -lt  (Get-Date).AddDays(-1 * $fileDays)

    Write-Host "=================================="

    If ($logFiles.Count -gt 0)
    {
        #Compress log files
        $logFiles = Get-ChildItem $LogFolderPath -Filter *.* | Where LastWriteTime -lt  (Get-Date).AddDays(-1 * $fileDays) | Compress-Archive -DestinationPath $BackupZip

        Write-Host "Archiving "$LogFolderPath -f Yellow
        Write-Host "to: "$ArchiveFileName -f Yellow

        IF (Test-Path $BackupZip) {
            If ((Get-Item $BackupZip).length -gt 0kb) {
            ClearFolder $LogFolderPath $fileDays
            }
        }
    }
    else
    {
        Write-Host "Nothing to cleanup" -F Green
    }


    Write-Host "=================================="
}
#=================================================
ClearFolder $ArchiveDir $KeepTheArchivesFor
#=================================================
ArchiveFolder "HFM_0" "D:\Oracle\Middleware\user_projects\domains\EPMSystem\servers\FinancialReporting0\logs" 100