[CmdletBinding()]
 Param(
 [Parameter(Mandatory=$True,
 Position=1)]
 [int]$DriveSize,
 [Parameter(Mandatory=$True)]
 [string]$DriveLetter,
 [Parameter(Mandatory=$True)]
 [string]$DriveType,
 [Parameter(Mandatory=$True)]
 [string]$Label
 )
 
# Set Log Path
$Path = "C:\Logs\DiskConfig"
 
# Check Log Path exists and Create if it does not
If(-not(Test-Path -Path $Path))
 {
 New-Item -Path $Path -ItemType Directory -Force | Out-Null
 }
 
# Start Logging
Start-Transcript -Path "$Path\Log-$DriveLetter-Drive.txt"
Write-Output "Check Requested Drive Size"
 
# Confirm DiskSize is NOT Zero
If ($DriveSize -ne 0){
 Write-Output "Requested Drive Size is $DriveSize"
  
 # Confirm DiskType is GPT or MBR
 If (($DriveType -eq "GPT") -or ($DriveType -eq "MBR")){
 Write-Output "Listing All Drives"
 
 $dpscript = @"
 list disk
"@
 
 # Run Diskpart with list disk and Save the output into an array
 [array]$Temp = $dpscript | diskpart
 
 # Get all the lines starting with the word Disk into an array
 ForEach ($Line in $Temp){
 If ($Line.StartsWith(" Disk")){
 [array]$Disks += $Line
 }
 }
 
 # Get Total Number of Disk
 $DiskCount = $Disks.Count
 
 # Get DiskNumber, Size etc for each Disk into an Array
 For ($i=1;$i -le ($Disks.count-1);$i++){
 $currLine = $Disks[$i]
 $currLine -Match " Disk (?<disknum>...) +(?<sts>.............) +(?<sz>.......) +(?<fr>.......) +(?<dyn>...) +(?<gpt>...)" | Out-Null
 $DiskObj = New-Object PSObject
 Add-Member -InputObject $DiskObj -MemberType NoteProperty -Name "DiskNumber" -Value $Matches['disknum'].Trim()
 Add-Member -InputObject $DiskObj -MemberType NoteProperty -Name "Status" -Value $Matches['sts'].Trim()
 Add-Member -InputObject $DiskObj -MemberType NoteProperty -Name "Size" -Value $Matches['sz'].Trim()
 Add-Member -InputObject $DiskObj -MemberType NoteProperty -Name "Free" -Value $Matches['fr'].Trim()
 Add-Member -InputObject $DiskObj -MemberType NoteProperty -Name "Dyn" -Value $Matches['dyn'].Trim()
 Add-Member -InputObject $DiskObj -MemberType NoteProperty -Name "Gpt" -Value $Matches['gpt'].Trim()
 [array]$DiskResults += $DiskObj
 }
 
 # Check each Disk and Get DiskNumber that of requested size and offline
 Foreach ($DiskResult in $DiskResults){
 if($DiskResult.Size -eq "$DriveSize GB"){
 $DiskResult
 Foreach ($Disk in $DiskResult){
 # Check each Disk that is either offline or online and Free Disk space matches the requested Disk Size
 if(($Disk.Status -eq 'offline')-or($Disk.Status -eq 'online')-and($Disk.Free -eq "$DriveSize GB")){
 $DiskNum = $Disk.DiskNumber
 }
 }
 }
 }
 
 # Ensure that the DiskNumber is not Disk 0 which would be OS Disk
 Write-Output "Verifying if selected disk is OS Disk (Disk 0)"
 If($DiskNum -ne 0){
  
 # Create Diskpart Answer file
 Write-Output "Selected disk is Disk $DiskNum"
 Write-Output "Generating Answer file for Diskpart - $DriveLetter Drive"
 New-Item -Path "$Path\$DriveLetter-Drive.txt" -ItemType file -force | OUT-NULL
 ADD-CONTENT -Path "$Path\$DriveLetter-Drive.txt" -Value "SELECT DISK $DiskNum"
 ADD-CONTENT -Path "$Path\$DriveLetter-Drive.txt" -Value "ONLINE DISK NOERR"
 ADD-CONTENT -Path "$Path\$DriveLetter-Drive.txt" -Value "ATTRIBUTES DISK CLEAR READONLY"
 ADD-CONTENT -Path "$Path\$DriveLetter-Drive.txt" -Value "CONVERT $DriveType NOERR"
 ADD-CONTENT -Path "$Path\$DriveLetter-Drive.txt" -Value "CREATE PARTITION PRIMARY"
 ADD-CONTENT -Path "$Path\$DriveLetter-Drive.txt" -Value "FORMAT FS=NTFS LABEL='$Label' QUICK"
 ADD-CONTENT -Path "$Path\$DriveLetter-Drive.txt" -Value "ASSIGN LETTER=$DriveLetter"
 Write-Output "Answer File for Diskpart generated Successfully"
 Write-Output "Running Diskpart with Answer File"
  
 # Run Diskpart with the Answer file generated as input
 DISKPART /S "$Path\$DriveLetter-Drive.txt"
 Write-Output "Drive Configuration Completed Successfully"
 }
 else{
 Write-Output "Selected disk is Disk $DiskNum which is OS Disk. No additional disk available."
 }
}
 else{
 Write-Output "Invalid DriveType - Requested DriveType is $DriveType - Skipping Drive Configuration"
 }
}
else{
Write-Output "Requested Drive Size is $DriveSize - Skipping Drive Configuration"
}
Stop-Transcript