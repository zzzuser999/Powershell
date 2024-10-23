<<<<<<< HEAD
﻿$var_date = get-date -Format "yyyyMMdd"
$var_name = "TMP-" + $var_date
$var_path = "C:\users\plmamro7\downloads"
=======
﻿$var_date = get-date -Format "yyyyMMdd"
$var_name = "TMP-" + $var_date
$var_path = "C:\users\plmamro7\downloads"
>>>>>>> origin/main
New-Item -ItemType Directory -Path $var_path -Name $var_name