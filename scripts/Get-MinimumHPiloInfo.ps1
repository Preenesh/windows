<# 
Author : Preenesh Nayanasudhan 
Script : Ping Multiple servers iLO IP provided in Text file Serverlist.txt 
Purpose : iLO Test Experiment - Ping Multiple Servers iLO and publish the result in CSV 
Pre-requisite : Create a Text File Serverlist.txt in the same path you save this script 
#>
  
# Input file 
$Servers = Get-Content "ServerList.txt"
$report = @() 
  
ForEach ($server in $Servers) 
{ 
    $HostName = [System.Net.Dns]::GetHostEntry($server).hostname 
    if (test-Connection -ComputerName $server -Count 3 -Quiet ) 
    { 
        $iLOIP = $($server); 
        $PingResult = 'ILO is Alive and Pinging'
        $XML = New-Object XML  
        $XML.Load("http://$server/xmldata?item=All") 
        $iLOSN = $($XML.RIMP.HSI.SBSN);
        $ServerType = $($XML.RIMP.HSI.SPN); 
        $ProductID = $($XML.RIMP.HSI.PRODUCTID); 
        $ILOType = $($XML.RIMP.MP.PN);  
        $iLOFirmware = $($XML.RIMP.MP.FWRI) 
        $tempreport = New-Object PSObject 
        $tempreport | Add-Member NoteProperty 'ILO IP' $server
        $tempreport | Add-Member NoteProperty 'Ping Result' $PingResult
        $tempreport | Add-Member NoteProperty 'ILO HostName' $HostName
        $tempreport | Add-Member NoteProperty 'ILO Serial NUmber' $iLOSN 
        $tempreport | Add-Member NoteProperty 'Server Type' $ServerType
        $tempreport | Add-Member NoteProperty 'Product ID' $ProductID
        $tempreport | Add-Member NoteProperty 'ILO Type' $ILOType
        $tempreport | Add-Member NoteProperty 'ILO Firmware' $iLOFirmware 
        $report += $tempreport
    }  
    else 
        {  
        $iLOIP = $($server); 
        $PingResult = 'ILO Seems dead NOT Pinging'
        $tempreport = New-Object PSObject 
        $tempreport | Add-Member NoteProperty 'ILO IP' $server
        $tempreport | Add-Member NoteProperty 'Ping Result' $PingResult
        $tempreport | Add-Member NoteProperty 'ILO HostName' $HostName
        $report += $tempreport
    } 
 } 
$report | Export-Csv -NoTypeInformation ('iLO_Timeout_Test.csv')