<#
This Script is meant to be run on the OU where Disabled objects are moved into. 
When the object is Re-enabled this script will Move it back into the OU in the Description field of the Computer.
#>

[cmdletbinding()]
param (
 [Alias('DisabledOU')]
 [string]$OU
 )

Function MoveReEnabledMachines{
$Computers = Get-ADComputer -Filter {Enabled -eq $true} -SearchBase $OU -Properties Description
$Computers
    If($Computers){
      Foreach($Computer in $Computers){
      $error.clear()
       $MachineName = $Computer.Name
       $Desc = Get-ADComputer $MachineName -Properties Description | select Description -ExpandProperty Description | ForEach-Object {$_ -replace '^.*?,'}
       Try{Get-ADComputer -Identity $Computer | Set-ADComputer -Description " "
    		Get-ADComputer -Identity $Computer | Move-ADObject -TargetPath $Desc
	
    	} Catch {"Failure: $MachineName Was Unable To Be Moved To $Desc"}
        if (!$error) {"Success: $MachineName : Has Been Moved To $Desc "}
        }
    }
    Else{
    $DateTimeBefore = (Get-Date).AddDays(-1).ToString('MM-dd-yy')
    $DateTime = (Get-Date).ToString('MM-dd-yy hh:mm')

    "No Computers Needed To Be Moved Between: $DateTimeBefore and $DateTime"
    }
}
# main

MoveReEnabledMachines
