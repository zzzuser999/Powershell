$var_date = Get-Date
$path = "C:\temp"
#$var_logfileName = $path\current_software_log_$(get-date -f yyyy-MM-dd).txt
New-Item -Type file -Path S:\LOGS\HFM\FileTransferDeleteLog.txt
Get-ChildItem -Path "D:\Oracle\Middleware\user_projects\epmsystem2\products\FinancialManagement\FileTransferData\" -Directory -recurse | Where-Object {$_.LastWriteTime -le $var_date.Adddays(-61)} | Remove-Item -recurse -force -Verbose 4>&1 | Add-Content S:\Users\PLMAMRO7\Desktop\xxxdeletelog.log