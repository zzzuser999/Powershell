get-process | Group-Object -Property ProcessName | 
% {
    [PSCustomObject]@{
        ProcessName = $_.Name
        Mem_MB = [math]::Round(($_.Group|Measure-Object WorkingSet64 -Sum).Sum / 1MB, 0)
        ProcessCount = $_.Count
    }
} | sort -desc Mem_MB | Select-Object -First 25