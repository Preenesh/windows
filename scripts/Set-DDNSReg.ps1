$Nics = Get-WmiObject -Class win32_NetworkAdapterconfiguration | Where-Object {$_.IPEnabled -eq "True"}
foreach ($Nic in $Nics)
   {
        $Nic.SetDynamicDNSRegistration($true)
   }