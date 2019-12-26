#Title: PSLauncher
#Version: 1.4.0
#Authors: Rory Maher, Michael Agu
#Date: 15th November 2019
#Description: Elevates approved applications using local Administrator credentials

param (
    # Input file
    [Parameter(Mandatory = $true)]
    [string]
    $Application,

    # Password definition for First time install
    [Parameter(Mandatory = $false)]
    [string]
    $USPW
)

$Script:AppName = "PSLauncher"
$Script:username = "Admin"
$Script:AppRoot = "$env:ProgramData\$Script:AppName"
$Script:LogLocation = "$env:LocalAppData\$Script:AppName\Logs"
$Script:LogName = (get-date -format "dd-MM-yyyy").ToString() + ".LOG"
$Script:FileName = $MyInvocation.MyCommand.Name
$Script:ApplicationPath = "$Script:AppRoot\$Script:FileName"
$Script:CurrentPath = "$PSScriptRoot\$Script:FileName"
$Script:LauncherError = "$Script:AppRoot\LauncherError.txt"
$Script:RegKey = "HKLM:\Software\$Script:AppName"
$Script:ManifestLocation = "https://raw.githubusercontent.com/openmoto/helpdesk/master/PSLauncher/manifest.json"
$Script:Manifest = ""
$Script:hashResult = $false
$Script:trustedNoHash = $false

Add-Type -AssemblyName PresentationFramework
function Start-Launcher {
    # Checking core directories and files
    # Application root
    if (Test-Path -Path $Script:AppRoot) { } else {
        try {
            New-Item -ItemType Directory -Path $Script:AppRoot
        }
        catch {
            "Unable to create root folder at: $Script:AppRoot" > $Script:LauncherError
            return 1
        }
    }
    # Check root Log location
    if (Test-Path -Path $Script:LogLocation) { } else {
        try {
            New-Item -ItemType Directory -Path $Script:LogLocation
        }
        catch {
            "Unable to create log folder at: $Script:LogLocation" > $Script:LauncherError
            return 1
        }
    }
    # Check log files path
    if (Test-Path -Path $Script:LogLocation\$Script:LogName) { } else {
        try {
            New-Item -ItemType File -Path $LogLocation\$LogName
        }
        catch {
            "Unable to create log file at: $Script:LogLocation\$Script:LogName" > $Script:LauncherError
            return 1
        }
    }
    # Register the application as a source in the event log
    if (!([Diagnostics.EventLog]::SourceExists("$Script:AppName"))) {
        try {
            New-EventLog -LogName Application -Source $Script:AppName
            Write-EventLog -LogName Application -Source "$Script:AppName" -EventID 0 -Message "Created application log successfully" -EntryType Information
        }
        catch {
            "Unable to register event log" > $Script:LauncherError
            return 1
        }
    }
    # Registry path Test/Creation
    if (Test-Path -Path $Script:RegKey) { } else {
        try {
            New-Item -Path $Script:RegKey
        }
        catch {
            "Unable to find or create root registry key" > $Script:LauncherError
            return 1
        }
    }
    # Download JSON and set variables
    try {
        (New-Object System.Net.WebClient).DownloadFile("$Script:ManifestLocation", "$Script:Approot\manifest.json")
        #Invoke-WebRequest -Uri $Script:ManifestLocation -OutFile "$Script:AppRoot\manifest.json"
    }
    catch {
        "Unable to find or download JSON manifest" > $Script:LauncherError
        return 1
    }
    # Process the JSON Manifest
    try {
        $Script:Manifest = Get-Content -Path "$Script:Approot\manifest.json" | ConvertFrom-Json
    }
    catch {
        "Unable to load JSON object" > $Script:LauncherError
        return 1
    }
    # Remove JSON file to prevent tampering
    try {
        Remove-Item -Path "$Script:AppRoot\manifest.json"
    }
    catch {
        "Unable to remove JSON file > $Script:LauncherError"
    }

    # Set variables from the manifest
    $Script:DefaultError = $Script:Manifest.defaultError
    $Script:HashFailureError = $Script:Manifest.HashFailureError
    $Script:HashVersionError = $Script:Manifest.HashVersionError
}
function Set-Log {
    param (
        # Value of the message we're logging
        [Parameter(Mandatory = $true)]
        [string]
        $Message,

        # Event ID if we're logging it to the event viewer
        [Parameter(Mandatory = $false)]
        [int]
        $ID
    )
    $LogTime = (Get-Date).ToString()
    $LogTime + " : " + $Message >> "$Script:LogLocation\$LogName"

    if ($null -ne $ID) {
        if ($ID -le 100) {
            # ID's less than 100 are marked as errors
            Write-EventLog -LogName Application -Source "$Script:AppName" -EventID $ID -Message $Message -EntryType Error
        }
        else {
            # Over 100 is for information
            Write-EventLog -LogName Application -Source "$Script:AppName" -EventID $ID -Message $Message -EntryType Information
        }

    }
}

function Save-Password {
    # Encryption key creation
    Set-Log "Starting Password key creation" 110
    try {
        $AESKey = New-Object Byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
        Set-Log "Encryption key generation completed" 110
    }
    catch {
        Set-Log "Unable to perform encryption key creation" 10
        return 10
    }

    # Perform Password translation, key creation and saving
    # Create a secure string from the password value
    try {
        $sPwd = $Script:USPW | ConvertTo-SecureString -AsPlainText -Force
        $ePwd = $sPwd | convertfrom-securestring -key $AESKey
        Set-Log "Password encrypted succesfully" 110
    }
    catch {
        Set-Log "Password encryption failed, error secure string conversion or encryption" 10
        return 10
    }
    # Set the key and password registry keys
    try {
        New-ItemProperty -Path $Script:RegKey -Name BAK23432 -Value $ePwd
        New-ItemProperty -Path $Script:RegKey -Name BAK0983 -Value $AESKey
        Set-Log "Registry keys added successfully" 110
    }
    catch {
        Set-Log "Error adding registry keys to the store" 10
        return 10
    }
}

function Compare-FileHash {
    param(
        # Parameter for the hash of the current file
        [Parameter(Mandatory = $true)]
        [string]
        $hash
    )
    Set-Log "Comparing filehash for application $Script:Application" 120
    # Get application information
    $desc = (get-item $Script:Application).Versioninfo.FileDescription
    $name = (get-item $Script:Application).Versioninfo.ProductName

    foreach ($app in $Script:Manifest.apps) {
        # Compare hash
        if ($app.MD5 -match $hash) {
            Set-Log "Matching hash found" 120
            $Script:hashResult = $true
            return $true
        }
        if ((!$Script:hashResult) -and ($app.Name -like $desc -or $app.Name -like $name)) {
            [System.Windows.MessageBox]::Show($Script:HashVersionError, "Application Error", "OK", "Error")
            $Script:hashResult = $false
        }
    }

    if (!$Script:hashResult) {
        [System.Windows.MessageBox]::Show($Script:HashFailureError, "Application Error", "OK", "Error")
    }
    return $Script:hashResult
}

# Function to put a shortcut to our application on all user desktops
function Save-Shortcut {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\$Script:AppName.lnk")
    $Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $Shortcut.Arguments = "-executionpolicy bypass -noprofile -file $Script:ApplicationPath"
    $Shortcut.Save()

    if ($Script:CurrentPath -ne $Script:ApplicationPath) {
        try {
            Copy-Item -Path $Script:CurrentPath -Destination $Script:ApplicationPath
        }
        catch {
            Set-Log "Unable to copy application to root folder" 6
        }

    }
}
# Runtime Logic
$checks = Start-Launcher
if ($checks -eq 1) {
    # Guaranteed to have script issues if we ignore potential startup errors
    return 0
}

Set-Log "Program Startup... Checks passed" 101

if ("" -eq $Script:USPW) {
    # Empty string means no password, because it won't treat empty as null
    # Application time

    #Time to create the credential
    Set-Log "No password provided, entering application mode" 130
    # Getting reg values
    try {
        $rPwd = (Get-ItemProperty -Path $Script:RegKey)."BAK23432"
        $rKey = (Get-ItemProperty -Path $Script:RegKey)."BAK0983"
        Set-Log "Registry key fetching successfull" 130
    }
    catch {
        Set-Log "Failed to grab registry keys" 30
        return 3
    }

    # Create credential object
    try {
        $sPwd = $rPwd | convertto-securestring -key $rKey
        $credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $Script:username, $sPwd
        Set-Log "Created credentials successfully" 130
    }
    catch {
        Set-Log "Failed to create credentials" 30
        return 3
    }
    try {
        # If it's a shortcut to another application
        if ($Script:Application -match "\.lnk") {
            Set-Log "Converting shortcut to path" 140
            # Create shell object we'll use to mimic the shortcut
            $sh = New-Object -COM WScript.Shell
            # Reassign the application variable to reflect the shortcut path
            $Script:Application = $sh.CreateShortcut($Script:Application).TargetPath
        }
    }
    catch {
        Set-Log "Failed to convert shortcut to path" 40
        return 4
    }
    
    $hash = (Get-FileHash $Script:Application -Algorithm MD5).Hash
    $resulthash = Compare-FileHash $hash

    # Elevation phase
    try {

        # Run the application
        if ($resulthash) {
            Set-Log "Hashing was successfull" 150
            try {
                Start-Process powershell.exe -credential $credObject -ArgumentList "Start-Process '$Script:Application' -verb runas"
                Set-Log "Application $Script:Application was elevated with the credential object $Script:username" 150
            }
            catch {
                Set-Log "Elevation error, please check your credential object" 5
            }
        }
    }
    catch {
        Set-Log "Could not create elevated Session, please check your computer configuration" 20
        return 2
    }
}
else {
    Write-Host "We're setting the password as $Script:USPW"
    Save-Password # Save password details
    Save-Shortcut # Save shortcut to all desktops
}