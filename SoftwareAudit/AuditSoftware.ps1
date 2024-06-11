#requires -version 3
<#
.SYNOPSIS
  .

.DESCRIPTION
  .

.NOTES
  Version:        1.0
  Author:         Tomasz Redzik (tomasz.redzik@pl.abb.com)
  Creation Date:  17-04-2023
  Purpose/Change: Prepare Template
  Example:        .\CoronaSOX.ps1 -param
#>


#region begin boostrap
############### Bootstrap - Start ###############

#Clear the screen.
Clear-Host

#Import modules.

############### Bootstrap - End ###############
#endregion


#region begin input
############### Input - Start ###############

#Output.
$Output = @{
    Transcript = ("Process-" + ((Get-Date).ToString("ddMMyyyy-HHmmss")) + ".log")
}

#Generate basic variables
$Application = "Cylance Optics"
$Computers = Get-Content .\Computers.txt #| select -First 1
$ReportFile = "$(Get-Date -Format dd_MM_yyyy)-FireEye.csv"
$ScreenShotPath = "C:\Temp\Roboczy\TASK6983940"

############### Input - End ###############
#endregion


#region begin functions
############### Functions - Start ###############

#Write to the console.
Function Write-Console
{
    [cmdletbinding()]	
		
    Param
    (
        [Parameter(Mandatory=$false)][string]$Category,
        [Parameter(Mandatory=$false)][string]$Text
    )
 
    #If the input is empty.
    If([string]::IsNullOrEmpty($Text))
    {
        $Text = " "
    }
 
    #If category is not present.
    If([string]::IsNullOrEmpty($Category))
    {
        #Write to the console.
        Write-Output("[" + (Get-Date).ToString("dd/MM-yyyy HH:mm:ss") + "]: " + $Text + ".")
    }
    Else
    {
        #Write to the console.
        Write-Output("[" + (Get-Date).ToString("dd/MM-yyyy HH:mm:ss") + "][" + $Category + "]: " + $Text)
    }
}

#Make ScreenShot
function Make-ScreenShot {
    
    [CmdletBinding()]
    
    Param (

        [Parameter(Mandatory = $true)]$Path

    )
    
    #Set location
    $File = "$($Path)\$(get-date -Format yyyy_mm_dd_hh_mm_ss)_ScreenShot.bmp"

    Add-Type -AssemblyName System.Windows.Forms
    Add-type -AssemblyName System.Drawing

    #Get screen resolution
    $ScreenInfo = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $Width = $ScreenInfo.Width
    $Height = $ScreenInfo.Height
    $Left = $ScreenInfo.Left
    $Top = $ScreenInfo.Top

    #Get image of desktop by Width and Height of screen
    $Image = New-Object System.Drawing.Bitmap $Width, $Height

    #Create graphic
    $Graphic = [System.Drawing.Graphics]::FromImage($Image)

    #Capture screen
    $Graphic.CopyFromScreen($Left, $Top, 0, 0, $Image.Size)

    #Save to file
    $Image.Save($File) 
    
    #Write to terminal.
    Write-Console -Category ("Script") -Text ("ScreenShot has been saved to: $($File)")
}

############### Functions - End ###############
#endregion


#region begin main
############### Main - Start ###############

#Start transcript.
Start-Transcript -Path $Output.Transcript -Force | Out-Null

#Write to terminal.
Write-Console -Category ("Script") -Text (">>> THE SCRIPT HAS STARTED WORKING <<<")

#Write to terminal.
Write-Console -Category ("Script") -Text ("Start logging into file '$($Output.Transcript)'")

#Prepare empty array for Result
$Result = @()

#Write to terminal.
Write-Console -Category ("Script") -Text ("Start generating report for all computers")

#Generate Result one by one
foreach ($Computer in $Computers) {

    #Write to terminal.
    Write-Console -Category ("Script") -Text ("Get Application Details from $($Computer)")

    #Create new Cim Session
    $CimSession = New-CimSession -ComputerName $Computer

    #Get details about application remotly
    $ApplicationDetails = Get-CimInstance -ClassName Win32_Product -CimSession $CimSession | where {$_.Name -like "*$($Application)*"} | select PSComputerName, Name, Version, InstallDate

    #Prepare new entry
    $Entry = New-Object PSObject

    #Generate properties
    Add-Member -inputObject $Entry -memberType NoteProperty -name “Computer Name” -value $ApplicationDetails.PSComputerName
    Add-Member -inputObject $Entry -memberType NoteProperty -name “Application Name” -value $ApplicationDetails.Name
    Add-Member -inputObject $Entry -memberType NoteProperty -name “Application Version” -value $ApplicationDetails.Version
    Add-Member -inputObject $Entry -memberType NoteProperty -name “Install Date” -value $ApplicationDetails.InstallDate

    #Add new entry to Result Array
    $Result += $Entry

    #Clean-up
    Remove-CimSession $CimSession
    Remove-Variable Entry, CimSession, ApplicationDetails

}

############### Main - End ###############
#endregion


#region begin finalize
############### Finalize - Start ###############

#Write to terminal.
Write-Console -Category ("Script") -Text ("Generate Report in the CSV format")

#Generate Report as CSV file
$Result | Export-Csv -Path .\$ReportFile -Force -NoTypeInformation

#Get CheckSum for CSV file
$CSVCheckSum = Get-FileHash .\$ReportFile

#Write to terminal.
#Write-Console -Category ("Script") -Text ("The CheckSum for .\$ReportFile is: $($CSVCheckSum.Hash)")

#Write to terminal.
#Write-Console -Category ("Script") -Text ("Generate Report in the HTML format")

#Generate Report as HTML file
#$Result | ConvertTo-Html | Out-File .\CoronaSox.html

#Get CheckSum for HTML file
#$HTMLCheckSum = Get-FileHash .\CoronaSox.html

#Write to terminal.
#Write-Console -Category ("Script") -Text ("The CheckSum for .\CoronaSox.html is: $($HTMLCheckSum.Hash)")

#Write to terminal.
#Write-Console -Category ("Script") -Text ("Generate Report in the GUI")

#Generate Report in GUI mode
#$Result | Out-GridView

#Write to terminal.
Write-Console -Category ("Script") -Text (">>> THE SCRIPT HAS FINISHED THE JOB <<<")

#Make ScreenShot.
#Make-ScreenShot -Path $ScreenShotPath

#Stop transcript.
Stop-Transcript

############### Finalize - End ###############
#endregion