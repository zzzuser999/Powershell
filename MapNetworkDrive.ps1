$cred = Get-Credential -Credential ABB\PL-ADMIN-MM11
New-PSDrive -Name "S" -Root "\\xe-s-ITXDB01P.xe.abb.com\d$" -Persist -PSProvider "FileSystem" -Credential $cred