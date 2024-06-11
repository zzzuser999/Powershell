$folders =@("ABACUS11","ABACUSWK","DOCRep","FDMEE","HSS")
$lcmimportdir = "\\XF-S-NHFMDB01R.xe.abb.com\drLCMImport$\"
$lcmimportfile = "Import.xml"
$value = $counter = 0

Function Test-FileEmpty {
  Param ([Parameter(Mandatory = $true)][string]$file)

  if ((Test-Path -LiteralPath $file) -and (([IO.File]::ReadAllText($file)) -match '\S') -and (Get-Item $file).LastWriteTime -gt (Get-Date).AddDays(-1)) {return 100} else {return 0}
}

foreach ($folder in $folders)
{
$fileToCheck = $lcmimportdir + $folder + "\" + $lcmimportfile
$fvalue = Test-FileEmpty $fileToCheck
$counter = $counter + $fvalue
#Write-Host $counter
}

If ($counter -eq 500){return $true} else {return $false}