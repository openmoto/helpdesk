<#
This script assumes you have exported printer list with GetPrinterList and also downloaded printer drivers from vendor and extracted to a file share
using pnputil to export printer drivers will work but extracting downloaded printer driver from vendor gives you the latest browser and you also have option to link to different inf files depending on which (PCX5, PCL6, KX, 64 bit 32bit) you prefer.

Please check C:\setup\printerlogs.txt for errors
#>
 
$Kyocera = "\\..\printers\kyocera\PCL Driver\64bit\win81 and newer\prnkycl1.inf"
$Lexmark = "\\..\printers\lexmark\XM3100\LXAEHk50.inf"
$Sharp = "\\..\printers\sharp\English\PCL6\64bit\su0emenu.inf"
$Samsung = ""
$HP = ""

clear
$PrinterList=".\printerreport.csv"
$printers = Import-Csv $PrinterList

Function Install-Driver {
$brand = $null
	if ($drivername -like '*Kyocera*') {$brand = $Kyocera}
	if ($drivername -like '*Lexmark*') {$brand = $Lexmark}
	if ($drivername -like '*Sharp*') {$brand = $Sharp}
	if ($drivername -like '*Samsung*') {$brand = $Samsung}
	if ($drivername -like '*HP*') {$brand = $HP}

	pnputil /add-driver $driver /install
	
}

function Install-Printer {

try {
Add-PrinterPort -Name $PrinterIP -PrinterHostAddress $PrinterIP -ErrorAction Stop
}
catch
{
$ErrorMessage = $_.Exception.Message
"Adding Printer Port  :"+$PrinterIP  | Out-file -FilePath C:\setup\printerlogs.txt -Force -NoClobber -Append 
"Error  :"+$ErrorMessage | Out-File -FilePath C:\setup\printerlogs.txt -Force -NoClobber -Append 
}

try {
Add-PrinterDriver -Name $DriverName -ErrorAction Stop
}
catch
{
$ErrorMessage = $_.Exception.Message
"Adding Printer Driver  :"+$DriverName | Out-file -FilePath C:\setup\printerlogs.txt -Force -NoClobber -Append 
"Error  :"+$ErrorMessage | Out-File -FilePath C:\setup\printerlogs.txt -Force -NoClobber -Append 
}

try {
Add-Printer -Name $name -DriverName $DriverName -PortName $PrinterIP -ErrorAction Stop
}
catch
{
$ErrorMessage = $_.Exception.Message
"Adding Printer  :"+$name  | Out-file -FilePath C:\setup\printerlogs.txt -Force -NoClobber -Append 
"Error  :"+$ErrorMessage | Out-File -FilePath C:\setup\printerlogs.txt -Force -NoClobber -Append 
}
}

$printers | Out-GridView -PassThru -Title 'Select a printer' | ForEach-Object {$Index,$Name,$PrinterIP,$DriverName = $_.Index,$_.Name,$_.PrinterIP,$_.DriverName}

Install-Driver
Start-Sleep -Seconds 5
Install-Printer 