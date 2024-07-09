function Test-Return {
    $results = @()
    foreach ($item in 1..5) {
        if ($item -eq 3) {
            $results += "Found item $item"
        }
        $results += "Processing item $item"
    }
    return $results
}

Test-Return
