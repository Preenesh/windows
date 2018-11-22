# Set Number of retries, Delay
    $retries = 5
    $secondsDelay = 10
    $retrycount = 0
    $completed = $false
          
        while (-not $completed){
# Run Command and Pass the Output into a File
            & netdom Join $env:COMPUTERNAME /PasswordM:$env:COMPUTERNAME$ /Domain:DM.COM\RODC0001.dm.com /ReadOnly | Out-File "C:\Join.txt"
            $a = Get-Content -Path "C:\Join.txt"
# Verify the command was successful
            if ($a -eq "The command complete successfully."){
                Write-Output ("Command succeeded.")
                $completed = $true
            }
# Sleep for few seconds and retry again until the retry count
            else                     
            {
                if ($retrycount -ge $retries){
                    Write-Output ("Command failed the maximum number of $retrycount times.")
                    break
                } else {
                    Write-Output ("Command failed. Retrying in $secondsDelay seconds.")
                    remove-item -path "C:\Join.txt" -force
                    Start-Sleep $secondsDelay
                    $retrycount++
                }
            }
    }