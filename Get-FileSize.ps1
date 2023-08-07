Get-Childitem -path  "E:\SQLDATA" | Sort-Object Length -Descending | Select-Object Name, @{Name="GBytes";Expression={ "{0:N0}" -f ($_.Length / 1MB) }}