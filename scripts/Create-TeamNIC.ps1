#=====================================================================================================================================
# NAME: 	Create-TeamNIC.ps1                  	       
# AUTHOR: 	Preenesh Nayanasudhan       					
#======================================================================================================================================


# Wait until NIC Teaming Status is UP
function Wait-NICStatus ($TeamName, $desiredstate)
{
    while ($true)
    {
        # Get the Current Status of the NIC
        $currentstate = (Get-NetLbfoTeam -Name $TeamName).Status
        # Check if the Status is in the desired State
        if ($currentstate -eq $desiredstate)
        {
            Write-Output "$(Get-Date) NIC Team - $TeamName is $currentstate"
            break;
        }
        Write-Output "$(Get-Date) Current Status of NIC Team - $TeamName is $currentstate, Waiting to be $desiredstate"
        Sleep -Seconds 5
    }
}

$NICTeamName = "Team-DM"
$PhyNICs = (Get-NetAdapter -Physical | Select-Object -ExpandProperty Name | Sort-Object)
New-NetLbfoTeam -Name $NICTeamName -TeamMembers $PhyNICs -Confirm:$false
Wait-NICStatus -TeamName $NICTeamName -desiredstate "Up"