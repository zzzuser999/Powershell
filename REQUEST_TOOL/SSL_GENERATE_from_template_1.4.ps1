Write-Host "#----------------------------------------------------------------------------#"
Write-Host "#----------| S S L  CSR GENERATOR by 1ABB Operations   v 1.4   |-------------#"
Write-Host "#----------| Raport changes to marcin.d.robak@pl.abb.com       |-------------#"
Write-Host "#----------------------------------------------------------------------------#"

#---------------- SETTINGS ----------------------
$CertFolder = $Path = Split-Path -Path $MyInvocation.MyCommand.Path
#------------------------------------------------

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }
 
# Run your code that needs to be elevated here
$domain = read-host "Enter domain" #-assecurestring
#------------------------------------------------
#-- generate
$template = Get-Content $CertFolder\template.inf

$Subject = $template[5].Split(',');
$Subject[0] = $Subject[0].Substring(0,12) + $domain
$template[5] =$Subject[0]+","+$Subject[1]+","+$Subject[2]+","+$Subject[3]

new-item -ItemType Directory -Path "$CertFolder\REQUESTS\" | Out-Null

$FileInf = "$CertFolder\REQUESTS\$domain.inf"
$FileReq = "$CertFolder\REQUESTS\$domain.req"

$template | Out-File $FileInf

Write-host "---------------------------------------------------"
Write-host "Ganerating CSR for $domain"
certreq -new $FileInf $FileReq
Write-host "---------------------------------------------------"
Remove-Item $FileInf | Out-Null
#------------------------------------------------
Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")