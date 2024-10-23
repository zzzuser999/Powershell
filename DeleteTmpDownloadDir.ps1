$var_date = get-date -Format "yyyyMMdd"
$var_name = "TMP-" + $var_date
$var_path = "C:\users\plmamro7\downloads\" + $var_name
Remove-Item -Path $var_path