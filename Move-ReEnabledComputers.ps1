<#
This Script is meant to be run on the OU where Disabled objects are moved into. 
When the object is Re-enabled this script will Move it back into the OU in the Description field of the Computer.
#>


[cmdletbinding()]
param (
 [Parameter(Mandatory = $True)]
 [Alias('DCs')]
 [string[]]$DomainControllers,
 [Parameter(Mandatory = $True)]
 [System.Management.Automation.PSCredential]$ADCredential,
 [Parameter(Mandatory = $True)]
 [Alias('wi')]
 [switch]$WhatIf = $True
)
$DisabledOU = "OU=Disabled_Computer_Objects,DC=chico,DC=usd"


function New-ADSession ([string[]]$cmdlets, $dc) {
 $adSession = New-PSSession -ComputerName $DC -Credential $ADCredential
 Import-PSSession -Session $adSession -Module ActiveDirectory -CommandName $cmdlets -AllowClobber | Out-Null
}

Function MoveReEnabledMachines{
$Computers = Get-ADComputer -Filter {Enabled -eq $true} -SearchBase $DisabledOU -Properties Description -Whatif:$WhatIf
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
}
# main
. .\lib\Clear-SessionData.ps1
. .\lib\Select-DomainController.ps1
. .\lib\Show-TestRun.ps1

MoveReEnabledMachines


