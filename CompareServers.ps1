#requires -version 3
<#
.SYNOPSIS
  .

.DESCRIPTION
 This script was created for compare two servers and find difference between these two servers.
  .

.NOTES
  Version:        1.0
  Author:         Tomasz Redzik (tomasz.redzik@pl.abb.com)
  Creation Date:  07-08-2024
  Purpose/Change: Prepare Template
  Example:        .\script.ps1 -param
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

# Output.
$Output = @{
    Transcript = ("Compare-SRVs_" + ((Get-Date).ToString("ddMMyyyy-HHmmss")) + ".log")
}

# Get Servers
Write-Host "GET ALL SERVERS"
$Srv1 = Read-Host "Please provide the full DNS name for the first server"
$Srv2 = Read-Host "Please provide the full DNS name for the second server"

############### Input - End ###############
#endregion


#region begin functions
############### Functions - Start ###############

# Write to the console.
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

############### Functions - End ###############
#endregion


#region begin main
############### Main - Start ###############

# Start transcript.
Start-Transcript -Path $Output.Transcript -Force | Out-Null

# Write to terminal.
Write-Console -Category ("Script") -Text ("Start logging into file '$($Output.Transcript)'.")

# Write to terminal.
Write-Console -Category ("Script") -Text ("<<<<< SCRIPT WILL BE RUN FOR SERVERS $($Srv1) and $($Srv2) >>>>>")

##### COMPARE FEATURES BETWEEN TWO SERVERS #####

# Write to terminal.
Write-Console -Category ("Script") -Text ("<<<<< COMPARE FEATURES BETWEEN TWO SERVERS >>>>>")

# Write to terminal.
Write-Console -Category ("Script") -Text ("Get Windows Features from servers $($Srv1) and $($Srv2)")

# Get data from server Srv1
$ReferenceObject = Get-WindowsFeature -Computer $Srv1 | Where-Object InstallState -eq Installed

# Get data from server Srv2
$DifferenceObject = Get-WindowsFeature -Computer $Srv2 | Where-Object InstallState -eq Installed

# Write to terminal.
Write-Console -Category ("Script") -Text ("Compare Features between servers $($Srv1) and $($Srv2)")

# Change format
$FeaturesSrv1 = $ReferenceObject | ft -AutoSize -Wrap
$FeaturesSrv2 = $DifferenceObject | ft -AutoSize -Wrap

# Compare Roles and Features
$Result = Compare-Object -ReferenceObject $ReferenceObject.Name -DifferenceObject $DifferenceObject.Name -IncludeEqual


##### COMPARE SYSTEM VARIABLES BETWEEN TWO SERVERS #####

# Write to terminal.
Write-Console -Category ("Script") -Text ("<<<<< COMPARE SYSTEM VARIABLES BETWEEN TWO SERVERS >>>>>")

# Write to terminal.
Write-Console -Category ("Script") -Text ("Get system variables for servers $($Srv1) and $($Srv2)")

# Get System variables for both servers
$SystemVariablesSrv1 = Invoke-Command -ComputerName $Srv1 -ScriptBlock {Get-ChildItem -Path Env:}
$SystemVariablesSrv2 = Invoke-Command -ComputerName $Srv2 -ScriptBlock {Get-ChildItem -Path Env:}

# Write to terminal.
Write-Console -Category ("Script") -Text ("Compare system variables for servers $($Srv1) and $($Srv2)")

# Compare system variables
$SystemVariablesCompare = Compare-Object -ReferenceObject $SystemVariablesSrv1.Name -DifferenceObject $SystemVariablesSrv2.Name -IncludeEqual -ErrorAction SilentlyContinue
#$SystemVariablesCompare | select @{n='Roles or Features'; e={$_.InputObject}}, @{n = 'First Server'; e={$Srv1}}, @{n='Side Indicator'; e={$_.SideIndicator}}, @{n = 'Second Server'; e={$Srv2}}, @{n = 'Value on the First Server'; e={$SystemVariablesSrv1 | where {$_.Name -like "*$($_.Name)*"} | select Value}} #| ConvertTo-Html | Out-File Result.html -Force

#$SystemVariablesCompare | select @{n='Roles or Features'; e={$_.InputObject}}, @{n = 'First Server'; e={$Srv1}}, @{n='Side Indicator'; e={$_.SideIndicator}}, @{n = 'Second Server'; e={$Srv2}}, @{n = 'Value on the First Server'; e={$SystemVariablesSrv1 | where {$_.Name -like "*$($SystemVariablesCompare.InputObject)*"} | select Value}} #| ConvertTo-Html | Out-File Result.html -Force

$SystemVariablesResult = @()

foreach ($SystemVariableCompare in $SystemVariablesCompare) {

    $Entry = New-Object -TypeName psobject -ErrorAction SilentlyContinue

    [String]$Srv1Value = $SystemVariablesSrv1 | where {$_.Name -like "*$($SystemVariableCompare.InputObject)*"} -ErrorAction SilentlyContinue | select Value
    [String]$Srv2Value = $SystemVariablesSrv2 | where {$_.Name -like "*$($SystemVariableCompare.InputObject)*"} -ErrorAction SilentlyContinue | select Value

    Add-Member -InputObject $Entry -MemberType NoteProperty -Name "System Variable" -Value ($SystemVariableCompare.InputObject) -ErrorAction SilentlyContinue
    Add-Member -InputObject $Entry -MemberType NoteProperty -Name "First Server" -Value ($Srv1) -ErrorAction SilentlyContinue
    Add-Member -InputObject $Entry -MemberType NoteProperty -Name "Side Indicator" -Value ($SystemVariableCompare.SideIndicator) -ErrorAction SilentlyContinue
    Add-Member -InputObject $Entry -MemberType NoteProperty -Name "Second Server" -Value ($Srv2) -ErrorAction SilentlyContinue
    Add-Member -InputObject $Entry -MemberType NoteProperty -Name "Value on the First Server" -Value (($Srv1Value.Trim(" ", "}")).split("=")[1]) -ErrorAction SilentlyContinue
    Add-Member -InputObject $Entry -MemberType NoteProperty -Name "Value on the Second Server" -Value (($Srv2Value.Trim(" ", "}")).split("=")[1]) -ErrorAction SilentlyContinue

    $SystemVariablesResult += $Entry

}


##### COMPARE APPLICATIONS INSTALLED BETWEEN TWO SERVERS #####

# Write to terminal.
Write-Console -Category ("Script") -Text ("<<<<< COMPARE APPLICATIONS INSTALLED BETWEEN TWO SERVERS >>>>>")

# Write to terminal.
Write-Console -Category ("Script") -Text ("Get installed Applications on servers $($Srv1) and $($Srv2)")

# Get Applications
$ApplicationsSrv1 = Get-CimInstance -ClassName Win32_Product -ComputerName $Srv1 | Select -Property Name, Version | Sort -Property Name
$ApplicationsSrv2 = Get-CimInstance -ClassName Win32_Product -ComputerName $Srv2 | Select -Property Name, Version | Sort -Property Name

# Write to terminal.
Write-Console -Category ("Script") -Text ("Compare installed Applications on servers $($Srv1) and $($Srv2)")

# Generate result for compare installed Applicatinos
$ApplicationsResult = Compare-Object -ReferenceObject $ApplicationsSrv1.Name -DifferenceObject $ApplicationsSrv2.Name -IncludeEqual


##### COMPARE ALL JOBS ON TWO SERVERS #####

# Write to terminal.
Write-Console -Category ("Script") -Text ("<<<<< COMPARE ALL JOBS ON TWO SERVERS >>>>>")

#$TasksSrv1 = Invoke-Command -ComputerName $Srv1 -ScriptBlock {Get-ScheduledTask | select TaskPath, TaskName, State}
#$TasksSrv2 = Invoke-Command -ComputerName $Srv2 -ScriptBlock {Get-ScheduledTask | select TaskPath, TaskName, State}

# Write to terminal.
Write-Console -Category ("Script") -Text ("Get all Tasks from Task Scheduler on servers $($Srv1) and $($Srv2)")

[Array]$TasksSrv1 = Invoke-Command -ComputerName $Srv1 -ScriptBlock {

                # Import the Task Scheduler module
                Import-Module ScheduledTasks

                # Get all scheduled tasks
                $tasks = Get-ScheduledTask

                # Filter tasks that have an action that starts a program on the E: drive
                $filteredTasks = @()
                foreach ($task in $tasks) {
                    $taskDetails = Get-ScheduledTaskInfo -TaskName $task.TaskName -TaskPath $task.TaskPath
                    $taskActions = (Get-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath).Actions

                    foreach ($action in $taskActions) {
                        if ($action.Execute -like "E:\*" -or $action.WorkingDirectory -like "E:\*") {
            
                            $exportTask = $($task.TaskPath) + $($task.TaskName)

                            $xmlFile = $task.TaskName + '.xml'

                            schtasks /Query /TN $exportTask /XML > $xmlFile

                            $filteredTasks += [PSCustomObject]@{
                                TaskName = $task.TaskName
                                TaskPath = $task.TaskPath
                                State   = $task.State
                            }
            
                        }
                    }
                }

                # Output the filtered tasks
                #$filteredTasks | Format-Table TaskName, TaskPath, State
                return $filteredTasks
             }

[Array]$TasksSrv2 = Invoke-Command -ComputerName $Srv2 -ScriptBlock {

                # Import the Task Scheduler module
                Import-Module ScheduledTasks

                # Get all scheduled tasks
                $tasks = Get-ScheduledTask

                # Filter tasks that have an action that starts a program on the E: drive
                $filteredTasks = @()
                foreach ($task in $tasks) {
                    $taskDetails = Get-ScheduledTaskInfo -TaskName $task.TaskName -TaskPath $task.TaskPath
                    $taskActions = (Get-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath).Actions

                    foreach ($action in $taskActions) {
                        if ($action.Execute -like "E:\*" -or $action.WorkingDirectory -like "E:\*") {
            
                            $exportTask = $($task.TaskPath) + $($task.TaskName)

                            $xmlFile = $task.TaskName + '.xml'

                            schtasks /Query /TN $exportTask /XML > $xmlFile

                            $filteredTasks += [PSCustomObject]@{
                                TaskName = $task.TaskName
                                TaskPath = $task.TaskPath
                                State   = $task.State
                            }
            
                        }
                    }
                }

                # Output the filtered tasks
                #$filteredTasks | Format-Table TaskName, TaskPath, State
                return $filteredTasks
             }

# Write to terminal.
Write-Console -Category ("Script") -Text ("Compare all Tasks from servers $($Srv1) and $($Srv2)")

# Compare Tasks
$TasksResult = Compare-Object -ReferenceObject $TasksSrv1.TaskName -DifferenceObject $TasksSrv2.TaskName -IncludeEqual


##### COMPARE SETTINGS FOR DEFAULT WEBSITES #####

# Write to terminal.
Write-Console -Category ("Script") -Text ("<<<<< COMPARE SETTINGS FOR DEFAULT WEBSITES >>>>>")

# Write to terminal.
Write-Console -Category ("Script") -Text ("Get IIS configuration from servers $($Srv1) and $($Srv2)")

# Get IIS configuration
$IISbasicSRV1 = Invoke-Command -ComputerName $Srv1 -ScriptBlock {C:\Windows\System32\inetsrv\appcmd list config}
$IISbasicSRV2 = Invoke-Command -ComputerName $srv2 -ScriptBlock {C:\Windows\System32\inetsrv\appcmd list config}

############### Main - End ###############
#endregion


#region begin finalize
############### Finalize - Start ###############

# Write to terminal.
Write-Console -Category ("Script") -Text ("<<<<< START FINALIZE SECTION >>>>>")

# Write to terminal.
Write-Console -Category ("Script") -Text ("Generate Features and Roles result files for $($Srv1) and $($Srv2)")

# Generate result files for Features and Roles
$FeaturesSrv1 > .\$($Srv1).txt
$FeaturesSrv2 > .\$($Srv2).txt

$Result | Select @{n='Roles or Features'; e={$_.InputObject}}, @{n = 'First Server'; e={$Srv1}}, @{n='Side Indicator'; e={$_.SideIndicator}}, @{n = 'Second Server'; e={$Srv2}} | ConvertTo-Html | Out-File Roles_and_Features.html -Force

# Write to terminal.
Write-Console -Category ("Script") -Text ("Generate System Variables result file for $($Srv1) and $($Srv2)")

# Save result to the file
$SystemVariablesResult | Select @{n='System Variable'; e={$_.'System Variable'}}, @{n = 'First Server'; e={$Srv1}}, @{n='Side Indicator'; e={$_.'Side Indicator'}}, @{n = 'Second Server'; e={$Srv2}}, @{n='Value on the First Server'; e={$_.'Value on the First Server'}}, @{n='Value on the Second Server'; e={$_.'Value on the Second Server'}} | ConvertTo-Html | Out-File System_Variables.html -Force

# Write to terminal.
Write-Console -Category ("Script") -Text ("Generate installed Applications result file for $($Srv1) and $($Srv2)")

# Generate result file for Features and Roles
$ApplicationsResult | Select @{n='Application Name'; e={$_.InputObject}}, @{n = 'First Server'; e={$Srv1}}, @{n='Side Indicator'; e={$_.SideIndicator}}, @{n = 'Second Server'; e={$Srv2}} | ConvertTo-Html | Out-File ApplicationsResult.html -Force

# Write to terminal.
Write-Console -Category ("Script") -Text ("Generate Tasks Compare result files for $($Srv1) and $($Srv2)")

# Generate result files for Tasks from Task Scheduler
$TasksResult | Select @{n='Task Name'; e={$_.InputObject}}, @{n = 'First Server'; e={$Srv1}}, @{n='Side Indicator'; e={$_.SideIndicator}}, @{n = 'Second Server'; e={$Srv2}} | ConvertTo-Html | Out-File TasksResult.html -Force
$TasksSrv2 | Select TaskName, TaskPath, State, PSComputerName | Out-File .\$("Tasks" + "_" + $Srv2 + ".txt") -Force
$TasksSrv2 | Select TaskName, TaskPath, State, PSComputerName | Out-File .\$("Tasks" + "_" + $Srv2 + ".txt") -Force

# Write to terminal.
Write-Console -Category ("Script") -Text ("Generate IIS result files for $($Srv1) and $($Srv2)")

# Generate result files for IIS configuration
$IISbasicSRV1 | Out-File .\$("IIS" + "_" + $Srv1 + ".xml") -Force
$IISbasicSRV2 | Out-File .\$("IIS" + "_" + $Srv2 + ".xml") -Force

# Stop transcript.
Stop-Transcript

############### Finalize - End ###############
#endregion 


# XC-S-ZW01973.XC.ABB.COM
# XC-S-ZW02114.xc.ABB.COM