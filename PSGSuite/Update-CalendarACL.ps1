#Everyone in the specified domain will have all the other domains added to their calendar ACL
#Domain list is fetched from ddomains folder and the current domain as well as the template folder is excluded
# Usage : .\Workspace_CalendarACL.ps1 -domain "domainname"


[CmdletBinding()]
param(
    [Parameter(Mandatory)] [String]$domain
)

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null

#Required modules will auto install
$RequiredModules = @("PSGSuite")

#Install Required Modules
foreach ($Module in $RequiredModules) {
 if (!((Get-Module -Name $Module -ErrorAction SilentlyContinue).Name)) {
    Write-Output "Installng $Module"
    Install-Module -Name $Module -Scope AllUsers -Force
    Import-Module -Name $Module -Global
 }
}


#Set Application folders and paths
$Script = ([io.fileinfo]$MyInvocation.MyCommand.Definition)
$AppName = $Script.BaseName
$AppDir = $Script.DirectoryName
$Workspaces = Join-Path -Path $AppDir -ChildPath 'domains'
$Domains = (((Get-ChildItem $Workspaces -Directory).Name -notmatch "template" ) -notmatch $($domain))
$AppConfig = Get-Content -Path (Join-Path -Path $AppDir -ChildPath 'config.json') |  ConvertFrom-Json -ErrorAction SilentlyContinue
$LogName = (Get-Date -Format "yyyy-MM-dd").ToString() +"_"+ $AppName + ".LOG"
$Log = Join-Path -Path (Join-Path -Path (Join-Path -Path (Join-Path -Path $AppDir -ChildPath 'domains') -ChildPath $domain) -ChildPath 'logs') -ChildPath $LogName
if (!(Test-Path -Path $Log)){
New-Item -Force -Path $Log -ItemType File
  }

Function Remove-OldLogs {
  $age = $Appconfig.LogAge
  $olderthan = (Get-Date).AddDays(-$age)
  $logs = Get-ChildItem -Path $AppDir -Filter *.LOG -Recurse | Where-Object LastWriteTime -LT $olderthan
  foreach ($x in $logs) {
  Remove-Item -Path $x.fullname -Force
  }
  }


function set-workspace {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$domain
    )

$workspace = Join-Path -Path $Workspaces -ChildPath $domain
$configfile = Join-Path -Path $Workspace -ChildPath 'config.json'

#Check if config file exists
if (!(Test-Path $configfile -PathType Leaf)) {
Write-Output "Config file does not exist for $($domain)"
Break
}

$config = Get-Content -Path $configfile | ConvertFrom-Json -ErrorAction SilentlyContinue
$config.P12KeyPath = Join-Path -Path $workspace -ChildPath $config.P12KeyPath

if (!(Test-Path $config.P12KeyPath)) {
Write-Output "P12 Key File does not exist for $($Domain), please check readme file in app directory"
Break
} Elseif ($config.ServiceAccountClientID.Length -eq 0) {
Write-Output "Please check ServiceAccountClientID in config file"
Break
}Elseif (!($config.AppEmail.Contains("@"))) {
Write-Output "Please check AppEmail in config file"
Break
}Elseif (!($config.AdminEmail.Contains("@"))) {
Write-Output "Please check AdminEmail in config file"
Break
}Elseif ($config.CustomerID.Length -eq 0) {
Write-Output "Please check CustomerID in config file"
Break
} Else {
Write-Output "Loading config file..."
}

try {
Set-PSGsuiteConfig -ConfigName $config.name `
-P12KeyPath $config.P12KeyPath `
-AppEmail $config.AppEmail `
-AdminEmail $config.AdminEmail `
-CustomerID $config.CustomerID `
-Domain $config.Domain `
-ServiceAccountClientID $config.ServiceAccountClientID
} 
    catch {
        Write-Output $_.Exception.message > $Logfile
} finally {
$error.Clear()

}

#Get account being managed
$GSAccount = Get-GSCustomer -ErrorAction SilentlyContinue
if (!($GSAccount.Id)) {
Write-Output "Unable to fectch Customer ID, please check configuration file"
} Else {
  #some service accounts connects but Customer Domain is blank, so confirming we can query the customer ID, if it's not empty, return the config file name as the domain being managed
  Write-Output "Now Managing $($Config.name)"
}
}

function Update-CalendarACL {

$users = (Get-GSUser -Filter *).User
foreach ($user in $users)
    { foreach ($d in $domains) {
    #Share user's calendar with the domain
    New-GSCalendarACL -User $user -Role reader -Value $d -Type domain -ErrorAction SilentlyContinue -Verbose
    }
}
}
Start-Transcript -Path $Log -Append
set-workspace -domain $domain -ErrorAction SilentlyContinue
Update-CalendarACL
Remove-OldLogs
Stop-Transcript