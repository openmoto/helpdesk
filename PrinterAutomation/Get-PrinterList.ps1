<#	
	.NOTES
	===========================================================================
	 Created with: 	Notepad++ v7.6.2
	 Created on:   	26-Dec-19 7:07 AM
	 Created by:   	Michael Agu
	 Organization: 	ClockWorx IT
	 Filename:     	Get-PrinterList.ps1
	===========================================================================
	.DESCRIPTION
		This is part 1 of a 2 part powershell script for (semi-) automating printer installation.
		This part collects printer information from a list of computers (or servers) and puts on a csv file
		Information collected:
		Name = The name used to describe the printer as seen on devices and printers page
		PrinterIP = IP address of the printer (only network printers that are locally installed are captured)
		DriverName = Name of the driver the printer is using
		You can edit the paths below to a network share
		$ReportFileName = ".\printerreport.csv"  - This is where the list of printers will be stored
		$PrintServersList=".\list.txt" - This is the list of computers or servers you are getting printers from, one computer or server name per line.
		$printerModels=".\models.csv" - The script will also generate a list of unique printer models, this is useful for knowing what drivers you will need if you have a lot of different models. Makes the list shorter.
		
		Please note that you will have to download printer drivers manually or use pnputil to export from the print servers, the drivers need to be specified in the next script for installation.
		After script completes, you may have to go through and make sure the DriverName per printer matches the exact name of the driver in the inf file, including the PCL6, KX, or similar, if it's not exact, install won't work. Small work to do compared to how many hours you'll save from manually downloading drivers and installing printers each time.
		
		Possible improvements would be to export the print drivers at the same time to a network share and add the path as additional column on the list so you can skip manual download during initial setup
#>

$ReportFileName = ".\printerreport.csv" 
$PrintServersList=".\list.txt"
$printerModels=".\models.csv"


$servers =  Get-Content -Path $PrintServersList 
$allprinters = @() 
foreach( $server in $servers ){ 
Write-Host "checking $server ..." 
$printers = $null 

$printers = Get-WmiObject -class Win32_Printer -computername $server | select Name,Shared,ShareName,Local, DriverName, PortName,@{n="PrinterIp";e={(((gwmi win32_tcpipprinterport -ComputerName $server -filter "name='$($_.PortName)'") | select HostAddress).HostAddress)}},@{n='PrintServer';e={$_.SystemName}}, Location,Comment,SpoolEnabled,Published
$allprinters += $printers 
 } 

$global:counter = 0
$printers = $allprinters | Where-Object{$_.PrinterIP}| Sort-Object -Property PrinterIP -Unique | Select -Property @{Name = "Index" ; Expression = {$global:counter; $global:counter++}},Name,PrinterIP,DriverName
$printers | Export-CSV -Path $ReportFileName -NoTypeInformation -Force -Encoding UTF8

$global:counter = 0
$models = $allprinters | Where-Object{$_.PrinterIP}| Sort-Object -Property DriverName -Unique | Select -Property @{Name = "Index" ; Expression = {$global:counter; $global:counter++}},Name,DriverName
$models | Export-CSV -Path $PrinterModels -NoTypeInformation -Force -Encoding UTF8