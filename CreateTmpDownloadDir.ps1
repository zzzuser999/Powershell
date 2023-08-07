$var_date = get-date -Format "yyyyMMdd"
$var_name = "TMP-" + $var_date
$var_path = "C:\users\plmamro7\downloads"
New-Item -ItemType Directory -Path $var_path -Name $var_name