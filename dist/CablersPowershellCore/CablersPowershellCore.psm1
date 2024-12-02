#TODO: I don't think this works on folders, only on files. May need to test and use a different Set-ACL command (containerinherit,objectinherit) for folders
#TODO: Test pipeline input
#TODO: Test multiple identities
#TODO: Test multiple paths
#TODO: May need to split out recurse into objectinherit and containerinherit, probably still keep recurse to do both as it's more intuitive, just need to validate it correctly (i.e. if recurse is specified with another, just use recurse)

<#

.SYNOPSIS

    Add permissions to a file or folder.

.DESCRIPTION

    Add permissions to a file or folder. Can accept an array of paths and or identities

.PARAMETER Path

    The path(s) to the file(s) or folder(s) to add permissions to.

.PARAMETER Identity

    The user(s) or group(s) to add permissions for.

.PARAMETER Recurse

    If specified, the permissions will be applied to all files and folders in the specified path.

.PARAMETER Permission

    The permission to add. Default is FullControl.
    Options are: FullControl, Modify, Read, Write

.PARAMETER Type

    The type of permission to add. Default is Allow.
    Options are: Allow, Deny

.EXAMPLE

    Add-Permissions -Path "C:\Temp\test.txt" -Identity "Everyone" -Permission "Read" -Type "Allow"

    This will add read permissions for the Everyone group to the file test.txt.

.EXAMPLE

    Add-Permissions "C:\Temp" -Identity "Everyone" -Permission "Read" -Type "Allow" -Recurse

    This will add read permissions for the Everyone group to all files and folders in the C:\Temp directory.

.EXAMPLE

    $SomeFolder = "C:\Temp"
    $SomeFolder | Add-Permissions -Identity "Everyone" -Permission "Read" -Type "Deny" -Recurse

    This will deny read permissions for Everyone to all files and folders in the C:\Temp directory.
    Definitely do not do this!

.EXAMPLE

    $SomeFolders = Get-ChildItem -Path "C:\Temp"
    $SomeFolders | Add-Permissions -Identity "Everyone" -Permission "Modify" -Type "Allow"

    This will add modify permissions for Everyone to all files and folders in the C:\Temp directory.


.EXAMPLE

    $SomeUsers = "User1", "User2", "User3"
    Add-Permissions -Path "C:\Temp" -Identity $SomeUsers -Permission "Write" -Type "Deny" -Recurse

    This will deny write permissions for User1, User2, and User3 to all files and folders in the C:\Temp directory.

.NOTES

    None

.OUTPUTS

    Object with the following properties:
    - Type
    - Permission
    - Recurse
    - User
    - Path

#>
function Add-Permissions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Identity,

        [Parameter()]
        [Switch]$Recurse,

        [Parameter()]
        [ValidateSet("FullControl", "Modify", "Read", "Write")]
        [string]$Permission = "FullControl",

        [Parameter()]
        [ValidateSet("Allow", "Deny")]
        [string]$Type = "Allow"
    )

    Begin {
        If (-not (Test-Path -Path $Path)) {
            Throw "Path does not exist: $Path"
        }
    }

    Process {
        try {
            foreach ($SinglePath in $Path) {
                $acl = Get-Acl -Path $SinglePath
                foreach ($user in $Identity) {
                    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, $Permission, $Type)
                    $acl.AddAccessRule($accessRule)
                    $Obj = [PSCustomObject]@{
                        Type       = $Type
                        Permission = $Permission
                        Recurse    = $Recurse
                        User       = $user
                        path       = $SinglePath
                    }

                    Write-Verbose $Obj
                }

                if ($Recurse) {
                    $acl | Set-Acl -Path $SinglePath
                }
                else {
                    $acl | Set-Acl -Path $SinglePath
                }
            }
        }
        catch {
            Write-Error "An error occurred while setting permissions: $_"
        }

    }

    End {
        Return $Obj
    }
}

#TODO Extensive testing
#TODO Add support for -WhatIf
#TODO Add support for -Verbose
#TODO Add support for -Debug?
#TODO Add comment based help

function Move-FileToArchive {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("FullName")]
        [string[]]$SourcePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ArchivePath

    )

    begin {
        Write-Debug "Begin"
        $accumulatedFiles = @()
    }

    process {
        Write-Debug "Process"
        # Accumulate the files before processing in the end block
        $accumulatedFiles += $SourcePath
    }

    end {
        Write-Debug "End"

        # All processing needs to be done in the end block to ensure all files are accumulated before processing

        Write-Debug "Source Path: $accumulatedFiles"
        Write-Debug "Source Path Count: $($accumulatedFiles.Count)"
        Write-Debug "Archive Path: $ArchivePath"

        Write-Debug "Getting Longest Common Prefix for Source Path(s)"
        $SourcePrefix = Get-LongestCommonPrefix (Split-Path $accumulatedFiles -Parent)

        Write-Debug "Common Prefix: $SourcePrefix"

        $TotalFiles = $SelectedFiles.Count
        $ProgressCounter = 0

        ForEach ($File in $accumulatedFiles) {

            $ProgressCounter++
            Write-Progress -Activity "Archiving Files" -Status "Processing file $ProgressCounter of $TotalFiles" -PercentComplete (($ProgressCounter / $TotalFiles) * 100)

            Write-Debug "File: $File"
            Write-Debug "Source Prefix: $SourcePrefix"
            Write-Debug "Archive Path: $ArchivePath"

            # Replace the common path prefix with the archive path
            $CleanArchivePath = $ArchivePath.TrimEnd('\')
            $SplitPath = Split-Path $File
            $FileName = Split-Path $File -Leaf
            Write-Debug "Split Path: $SplitPath"
            Write-Debug "File Name: $FileName"
            Write-Debug "Clean Archive Path: $CleanArchivePath"

            $ReplacedPath = $SplitPath -replace [regex]::Escape($SourcePrefix), $CleanArchivePath
            Write-Debug "Replaced Path: $ReplacedPath"

            $DestinationPath = Join-Path $ReplacedPath $FileName
            Write-Debug "DestinationPath: $DestinationPath"

            If (-not (Test-Path -Path (Split-Path -Path $DestinationPath))) {
                Write-Debug "Creating directory: $(Split-Path -Path $DestinationPath)"
                New-Item -ItemType Directory -Path (Split-Path -Path $DestinationPath) -Force | Out-Null
            }

            Write-Debug "Moving $File -> $DestinationPath"
            Try {
                Move-Item -Path $File -Destination $DestinationPath
            }
            Catch {
                Write-Error "Error moving file: $File - $_"
            }
            Write-Debug "Finished moving file`n"
        }
    }
}

# Compare two files to see if they are the same using Get-FileHash

Function Compare-Files {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SourceFile,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$ComparisonFile
    )

    Begin {

        # Validate the files exist
        If (-not (Test-Path $SourceFile)) {
            Throw "File at path $SourceFile does not exist"
        }
        If (-not (Test-Path $ComparisonFile)) {
            Throw "File at path $ComparisonFile does not exist"
        }
    }

    Process {

        $SourceHash = (Get-FileHash $SourceFile).Hash
        $ComparisonHash = (Get-FileHash $ComparisonFile).Hash

        $Object = [PSCustomObject]@{
            Match              = $true
            SourceFileHash     = $SourceHash
            ComparisonFileHash = $ComparisonHash
        }

        If ($SourceHash -eq $ComparisonHash) {
            Write-Output "Files are the same"
            $Object.Match = $True
        }
        Else {
            Write-Output "Files are different"
            $Object.Match = $False
        }

        Return $Object
    }

    End {

    }
}

#TODO: Test
#TODO: Comment based help

function Compress-7z {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ArchivePath,
        [Parameter(Mandatory = $false)]
        [switch]$DeleteOriginal

    )

    begin {
        # Validate the source path
        if (-not (Test-Path -Path $SourcePath -ErrorAction SilentlyContinue)) {
            Throw "Source path at $SourcePath does not exist"
        }
        # Validate the archive path
        if (-not (Test-Path -Path $ArchivePath -ErrorAction SilentlyContinue)) {
            Throw "Archive path at $ArchivePath does not exist"
        }
        # Check 7z command exists
        if (-not (Get-Command -Name "7z" -ErrorAction SilentlyContinue)) {
            Throw "7z not found in the PATH. Make sure it is installed."
        }
    }

    process {
        # Compress the 7z file
        $arguments = "a $ArchivePath $SourcePath"
        if ($DeleteOriginal) {
            $arguments += " -sdel"
        }
        try {
            Start-Process -FilePath "7z" -ArgumentList $arguments -Wait -NoNewWindow -PassThru
        }
        catch {
            Throw "Failed to compress $SourcePath to $ArchivePath - $_"
        }
    }

    end {

    }
}

#TODO: Comment based help
#TODO: Test

Function Expand-7z {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SourceFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationFolder,
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    Begin {
        #Validate the source file
        if (-not (Test-Path -Path $SourceFile -ErrorAction SilentlyContinue)) {
            Throw "Source file at path $SourceFile does not exist"
        }
        #Validate the destination folder
        if (-not (Test-Path -Path $DestinationFolder -ErrorAction SilentlyContinue)) {
            Throw "Destination folder at path $DestinationFolder does not exist"
        }
        #Check 7z command exists
        if (-not (Get-Command -Name "7z" -ErrorAction SilentlyContinue)) {
            Throw "7z not found in the PATH. Make sure it is installed."
        }
    }

    Process {
        #Extract the 7z file
        $arguments = "x $SourceFile -o $DestinationFolder"
        if ($Force) {
            $arguments += " -y"
        }
        Try {
            Start-Process -FilePath "7z" -ArgumentList $arguments -Wait -NoNewWindow -PassThru
        }
        Catch {
            Throw "Failed to extract $SourceFile to $DestinationFolder - $_"
        }
    }

    End {

    }
}


#TODO: Comment based help
#TODO: Add parameter to filter for specific drive
#TODO: Add parameter for simple output (e.g. "C:\ - 86 GB of 200 GB (40%) remaining")

Function Get-DiskSpace {
    [CmdletBinding()]
    param (
    )

    Begin {

    }

    Process {


        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[A-Z]:\\$" -and $null -eq $_.displayroot }
        $output = @()

        foreach ($drive in $drives) {
            $FreeSpace = $drive.Free / 1GB
            $TotalSpace = ($drive.Used + $drive.Free) / 1GB
            $UsedSpace = $drive.Used / 1GB
            #$Output += "$($drive.Name):\ - $($FreeSpace.ToString('0')) GB of $($TotalSpace.ToString('0')) GB remaining"
            $Output += [PSCustomObject]@{
                Drive       = $Drive.Name
                UsedSpace   = "$($UsedSpace.ToString('0')) GB"
                FreeSpace   = "$($FreeSpace.ToString('0')) GB"
                TotalSpace  = "$($TotalSpace.ToString('0')) GB"
                PercentUsed = "{0:P2}" -f ($UsedSpace / $TotalSpace)
                PercentFree = "{0:P2}" -f ($FreeSpace / $TotalSpace)
            }
        }

        return $Output

    }

    End {

    }

}

# Find all duplicate files in a folder and subfolders
# Duplicates will be displayed in a grid view and can be selected for archiving or deleting if required
# Selected files will be moved to a specified archive folder or deleted depending on params
# If not archiving, returns a list of duplicate files

#TODO Extensive testing
#TODO Add support for -WhatIf
#TODO Add support for -Verbose
#TODO Add support for -Debug?
#TODO Add comment based help

function Get-DuplicateFiles {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$FolderPath,
        [Parameter(ParameterSetName = "Archive")]
        [string]$ArchivePath,
        [Parameter(ParameterSetName = "Delete")]
        [switch]$Delete
    )

    begin {
        Write-Debug "Begin"
        #Validate the folder path
        if (-not (Test-Path -Path $FolderPath -ErrorAction SilentlyContinue)) {
            Throw "Folder at path $FolderPath does not exist"
        }

        #Validate the archive drive
        if ($PSCmdlet.ParameterSetName -eq "Archive") {
            if (-not (Test-Path -Path $ArchivePath -ErrorAction SilentlyContinue)) {
                Throw "Archive path at path $ArchivePath does not exist"
            }
        }
    }

    process {
        Write-Debug "Process"

        Write-Debug "Getting files in $FolderPath"
        $Files = Get-ChildItem -Path $FolderPath -File -Recurse

        # Group files by hash
        $GroupedFiles = $Files | Group-Object -Property { Get-FileHash $_.FullName | Select-Object -ExpandProperty Hash }

        Write-Debug "Filtering out Non-duplicate files"
        $DuplicateFiles = $GroupedFiles | Where-Object { $_.Count -gt 1 }

        # Create an empty array to store the selected files
        $DuplicateFilesArray = @()

        # Iterate through the duplicate files and add them to the array with their hash
        $DuplicateFiles | ForEach-Object {
            $Hash = $_.Name
            $DuplicateFilesArray += $_.Group | Select-Object FullName, @{Name = "Hash"; Expression = { $Hash } }
        }

        If ($DuplicateFilesArray.Count -eq 0) {
            Write-Output "No duplicate files found in $FolderPath"
            return $null
        }

        # If we are not archiving or deleting, return the list of duplicate files
        If ($PSCmdlet.ParameterSetName -eq "Default") {
            return $DuplicateFilesArray
        }

        # Display the selected files in a grid view and allow the user to select files for archiving or deleting
        $SelectedFiles = $DuplicateFilesArray | Select-Object FullName, Hash | Out-GridView -PassThru

        # If no files are selected, return
        If (-not $SelectedFiles) {
            Write-Output "No files selected"
            return $null
        }

        # Archive selected files
        If ($PSCmdlet.ParameterSetName -eq "Archive") {
            Archive-File -SourcePath $SelectedFiles.FullName -ArchivePath $ArchivePath
        }

        # Delete selected files
        If ($PSCmdlet.ParameterSetName -eq "Delete" -and $Delete) {

            $TotalFiles = $SelectedFiles.Count
            $Counter = 0

            Write-Debug "Beginning delete process"
            Foreach ($File in $SelectedFiles) {

                $Counter++
                Write-Progress -Activity "Archiving Files" -Status "Processing file $Counter of $TotalFiles" -PercentComplete (($Counter / $TotalFiles) * 100)

                Write-Debug "Deleting file: $($File.FullName)"
                Remove-Item -Path $File.FullName -Force
            }
        }
    }

    end {
        Write-Debug "End"
    }
}

#TODO: Add alias to module manifest - Get-InstalledApps

<#

.SYNOPSIS
    Get a list of installed software on a Windows device.

.DESCRIPTION
    Get a list of installed software on a Windows device.
    This function will search the registry for installed software and return:
    Name, version, install date, publisher, uninstall string, silent uninstall string, and GUID for each installed software.
    This will not find user installed software.
    This uses matching by default, so partial names can be used to search for software.

.PARAMETER SoftwareName
    The name of the software to search for. If not specified, all installed software will be returned.

.EXAMPLE
    Get-InstalledSoftware -SoftwareName "Google Chrome"

    This will return a list of all installed software with the name "Google Chrome".

.EXAMPLE

    Get-InstalledSoftware

    This will return a list of all installed software on the device.

.OUTPUTS
    PSCustomObject

#>
Function Get-InstalledSoftware {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [string]$SoftwareName
    )

    Begin {
        $Applist = @()
        If (!(Test-IsWindowsDevice)) {
            Throw "This script can only be run on a Windows operating system."
        }
    }

    Process {

        $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

        Try {
            $Apps = Get-ChildItem -Path $RegPath | Get-ItemProperty | Where-Object { $_.DisplayName -match $SoftwareName }
        }
        Catch {
            Throw "Error reading registry, check permissions and try again. $_"
        }

        Foreach ($App in $Apps) {

            # Parse the install date, needs multiple methods to account for different date formats but this should get just about everything.
            # Failing that just return the string instead.
            If ($null -ne $App.InstallDate) {
                Try {
                    $InstallDate = [datetime]::ParseExact($App.InstallDate, "yyyyMMdd", $null)
                }
                Catch {
                    try {
                        $InstallDate = [datetime]::Parse($App.InstallDate)
                    }
                    Catch {
                        $InstallDate = $App.InstallDate
                    }
                }
            }
            Else {
                $InstallDate = $App.InstallDate
            }

            $Obj = [PSCustomObject]@{
                Name                 = $App.DisplayName
                Version              = $App.DisplayVersion
                InstallDate          = $InstallDate
                Publisher            = $App.Publisher
                UninstallString      = $App.UninstallString
                QuietUninstallString = $App.QuietUninstallString
                GUID                 = $App.PSChildName
            }
            $Applist += $Obj
        }
        Return $Applist
    }

    End {

    }
}

#TODO: Comment based help
#TODO: Error handling?

Function Get-InternalIP {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Interface,
        [Parameter(Mandatory = $false)]
        [Switch]$ValidInternalNetwork # Only return interfaces with a 192 or 10 address
    )

    Begin {

    }

    Process {
        $AllInterfaces = Get-NetIPAddress -AddressFamily IPv4
        $MatchedInterfaces = $AllInterfaces | Where-Object { $_.InterfaceAlias -Match $Interface }
        If ($ValidInternalNetwork) {
            $MatchedInterfaces = $MatchedInterfaces | Where-Object { $_.IPAddress -Match "^(192|10)\." }
        }
        Return ($MatchedInterfaces | Select-Object IPAddress, InterfaceAlias, InterfaceIndex, PrefixLength, PrefixOrigin, AddressState)
    }

    End {

    }
}

<#

.SYNOPSIS

    Get the geographical location of an IP address using the iplocation.net API.

.DESCRIPTION

    Get the geographical location of an IP address using the iplocation.net API.
    Returns an object containing the IP address, country, country code, and ISP.

.PARAMETER IPAddress

    The IP address(es) to retrieve location information for. Accepts input from pipeline. Accepts multiple IP Addresses.

.EXAMPLE

    Get-IPAddressLocation -IPAddress "8.8.8.8"

    This will retrieve the location information for the IP address

.EXAMPLE

    $IPAddresses = "1.1.1.1", "8.8.8.8"
    $IPAddresses | Get-IPAddressLocation

    This will retrieve the location information for the IP addresses

#>
function Get-IPAddressLocation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$IPAddress
    )
    process {

        $results = @()

        $totalIPs = $IPAddress.Count
        $currentProgress = 0

        foreach ($IP in $IPAddress) {

            $currentProgress++
            $statusMessage = "Processing IP address: $IP"
            $percentComplete = ($currentProgress / $totalIPs) * 100
            Write-Progress -Activity "Retrieving IP Address Locations" -Status $statusMessage -PercentComplete $percentComplete

            Write-Verbose "Processing IP address: $IP"
            Try {
                # Parse the IP to confirm it's valid, this is more reliable than just casting it straight to an IP address object
                $validatedIP = [ipaddress]::Parse($IP)
                Write-Verbose "Successfully validated IP address format for $IP."
                Write-Debug "IP address $IP has been parsed as $validatedIP."
            }
            Catch {
                Write-Error "The specified IP Address $IP is not valid. Please provide a valid IP Address."
                continue
            }

            Write-Verbose "Retrieving location information for IP address: $validatedIP."
            Try {

                $response = Invoke-RestMethod -Uri "https://api.iplocation.net/?ip=$validatedIP" -Method Get
                Write-Verbose "Successfully retrieved location information for IP address: $validatedIP."
                Write-Debug "Response received: $($response | Out-String)"

                #Build
                $result = [PSCustomObject]@{
                    IPAddress   = $validatedIP.ToString()
                    Country     = $response.country_name
                    CountryCode = $response.country_code2
                    ISP         = $response.isp
                }

                $results += $result

            }
            Catch {
                if ($_.Exception.Response.StatusCode -eq "400") {
                    Write-Error "Bad Request: An error occurred while retrieving IP Address location information for ${IP}."
                }
                elseif ($_.Exception.Response.StatusCode -eq "401") {
                    Write-Error "Unauthorized: An error occurred while retrieving IP Address location information for ${IP}."
                }
                elseif ($_.Exception.Response.StatusCode -eq "403") {
                    Write-Error "Forbidden: An error occurred while retrieving IP Address location information for ${IP}."
                }
                elseif ($_.Exception.Response.StatusCode -eq "404") {
                    Write-Error "Not Found: An error occurred while retrieving IP Address location information for ${IP}."
                }
                else {
                    Write-Error "An error occurred while retrieving IP Address location information for ${IP}: $_"
                }
            }
            Write-Debug "Initiating a 500ms delay for rate limiting purposes."
            Start-Sleep -Milliseconds 500
        }

        Write-Progress -Activity "Retrieving IP Address Locations" -Status "Completed" -Completed

        Write-Verbose "Completed processing all IP addresses."
        return $results

    }
}

(curl icanhazip.com).Content | clip

function Get-PublicIP {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$CopyToClipboard
    )

    begin {

    }

    process {
        $PublicIP = (Invoke-RestMethod -Uri "https://icanhazip.com").Trim()

        If ($CopyToClipboard) {
            $PublicIP | Set-Clipboard
        }

        Return $PublicIP
    }

    end {

    }
}

<#

.SYNOPSIS
    Get the uptime of the local machine.

.DESCRIPTION
    Get the uptime of the local machine. Returns a custom object with the last reboot time and the uptime in the format dd.HH:mm:ss by default.
    Switch parameters can be used to display the uptime in days, minutes, hours, or seconds.

.PARAMETER Days
    Display the number of full days the machine has been up.

.PARAMETER Hours
    Display the number of full hours the machine has been up. For example a device online for 2 days will return 48

.PARAMETER Minutes
    Display the number of full minutes the machine has been up.

.PARAMETER Seconds
    Display the number of full seconds the machine has been up.


.EXAMPLE
    Get-Uptime

    Returns the last reboot time and the uptime in the format dd.HH:mm:ss.

.EXAMPLE
    Get-Uptime -Days

    Returns the number of full days the machine has been up.

.EXAMPLE

    Get-Uptime -Hours

    Returns the number of full hours the machine has been up.

#>


If (-not (Get-Command Get-Uptime -ErrorAction SilentlyContinue)) {
    function Get-Uptime {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidOverwritingBuiltInCmdlets", "", Justification = "Only loads in powershell 5.1.")]
        [CmdletBinding()]
        param(
            [Parameter()]
            [Switch]$Since
        )

        $LastBootTime = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime | Get-Date -Format "dd MMMM yyyy hh:mm:ss"
        $Today = Get-Date
        $Uptime = $Today.Date - (Get-Date $LastBootTime)

        If ($Since) {
            Return $LastBootTime
        }
        else {
            Return $Uptime
        }

    }
}

#Requires -Module PwnedPassCheck

#TODO: Comment based help
#TODO: Support for passphrases?
#TODO: Test rate limiting better, possibly reduce/remove it to speed up the process

function New-Password {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "Not actually changing anything on the system.")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Write-Host is fine here.")]
    [CmdletBinding(DefaultParameterSetName = "Simple")]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Simple")]
        [switch]$Simple,
        [Parameter(Mandatory = $true, ParameterSetName = "Strong")]
        [switch]$Strong,
        [Parameter(Mandatory = $true, ParameterSetName = "Random")]
        [switch]$Random,
        [Parameter(mandatory = $false, ParameterSetName = "Random")]
        [int]$Length = 12,
        [Parameter(Mandatory = $false, ParameterSetName = "Random")]
        [Switch]$NoSymbols,
        [Parameter(Mandatory = $false)]
        [Switch]$PwnCheck,
        [Parameter(Mandatory = $false)]
        [int]$NumberOfPasswords = 1,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,
        [Parameter(Mandatory = $false)]
        [Switch]$CopyToClipboard,
        [Parameter(Mandatory = $false)]
        [int]$SleepTime = 100 # In case it needs to be adjusted or increased to avoid rate limiting
    )

    begin {
        $Passwords = @()
        $GeneratedPasswords = 0
    }

    process {

        while ($GeneratedPasswords -lt $NumberOfPasswords) {

            $ProgressPercentage = [math]::Round(($GeneratedPasswords / $NumberOfPasswords) * 100)
            Write-Progress -Activity "Generating Passwords" -Status "$ProgressPercentage% Complete:" -PercentComplete $ProgressPercentage

            if ($Simple) {
                $Password = Invoke-RestMethod -Uri "https://www.dinopass.com/password/simple"
            }
            elseif ($Strong) {
                $Password = Invoke-RestMethod -Uri "https://www.dinopass.com/password/strong"
            }
            elseif ($Random) {
                If ($NoSymbols) {
                    $Password = Invoke-RestMethod -Uri "https://api.genratr.com/?length=$Length&uppercase&lowercase&numbers" | Select-Object -ExpandProperty password
                }
                else {
                    $Password = Invoke-RestMethod -Uri "https://api.genratr.com/?length=$Length&uppercase&lowercase&special&numbers" | Select-Object -ExpandProperty password
                }
            }

            if ($PwnCheck) {
                $Pwned = Get-PwnedPassword $Password | Select-Object -ExpandProperty SeenCount
                if ($Pwned -gt 0) {
                    Write-Host "Password $Password is pwned, generating a new one instead - Pwned count: $Pwned" -ForegroundColor Yellow
                    Continue
                }
            }

            $Passwords += $Password
            $GeneratedPasswords++


            # Sleep for a short period to avoid rate limiting
            Start-Sleep -Milliseconds $SleepTime
        }

        If ($OutputPath) {
            $Passwords | Out-File $OutputPath -Append -Force
        }

        if ($CopyToClipboard) {
            $Passwords | Set-Clipboard
        }

        Return $Passwords
    }

    end {

    }
}

#TODO: Add SupportsShouldProcess

<#

.SYNOPSIS

    Removes empty folders from a specified directory.

.DESCRIPTION

    Recursively removes empty folders from a specified directory. An empty folder is defined as a folder that contains no files or subfolders.
    Returns a list of removed folders.

.PARAMETER Path

    The source directory to remove empty folders from.

.EXAMPLE

    Remove-EmptyFolders -Path "C:\Temp"

    This example recursively removes empty folders from the "C:\Temp" directory.

.OUTPUTS

    A list of removed folders.

#>

function Remove-EmptyFolders {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    begin {

        $RemovedFolders = @()

        # Validate that the path is a folder
        if (-not (Test-Path -Path $Path -PathType Container)) {
            Throw "Path '$Path' does not exist or is not a folder."
        }
    }

    process {

        $folders = Get-ChildItem -LiteralPath $Path -Directory -Force

        # Recursive call to check subfolders
        foreach ($folder in $folders) {
            Remove-EmptyFolders $folder.FullName
        }

        # Check if the current folder is empty remove it
        if (Test-EmptyFolder $Path) {
            Try {
                if ($PSCmdlet.ShouldProcess($Path, "Remove-EmptyFolder")) {
                    Remove-Folder -Verbose:$VerbosePreference
                    $RemovedFolders += $Path
                }
            }
            Catch {
                Write-Warning "Failed to remove folder $Path. Error: $_"
            }
        }

        Return $RemovedFolders
    }

    end {

    }
}

#TODO Add recurse parameter? This would be a breaking change to other functions that use this function.

<#

.SYNOPSIS

    Removes a folder and all of its contents.

.DESCRIPTION

    This function will remove a folder and all of its contents.
    This will NOT remove system directories. These are currently hard coded as anything matching the following:
    "Windows"
    "Program Files"
    "ProgramData"
    "AppData"
    "System32"
    "netlogon"
    "sysvol"

.PARAMETER Path

    The path to the folder to remove.

.PARAMETER Force

    If specified, the function will attempt to take ownership of the folder if it fails to remove it due to unauthorized access and try again.
    This may still fail if the user running the script does not have the necessary permissions to take ownership.

.EXAMPLE

    Remove-Folder -Path "C:\Temp\MyFolder"

    This will remove the folder "C:\Temp\MyFolder" and all of its contents.

.EXAMPLE

    Remove-Folder -Path "C:\Temp\MyFolder" -Force

    This will remove the folder "C:\Temp\MyFolder" and all of its contents. If the removal fails due to unauthorized access, the function will attempt to take ownership of the folder and try again.

#>


function Remove-Folder {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'low')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    begin {
        #Validate that the path is not an important system directory
        if ($Path -match "Windows|Program Files|ProgramData|AppData|System32|netlogon|sysvol") {
            Throw "The path $Path is a system directory and cannot be removed by this command. It is very likely you shouldn't be removing this folder."
        }
        If (-Not (Test-Path $Path)) {
            Throw "The target directory $Path does not exist"
        }
    }

    process {

        if ($PSCmdlet.ShouldProcess($Path, "Removing folder and all contents")) {
            try {
                Remove-Item -Path $Path -Recurse -Force
                Write-Verbose "Successfully removed files at path: $Path"
            }
            catch [System.UnauthorizedAccessException] {
                Write-Warning "Failed to remove files at path: $Path due to unauthorized access. Error: $_"
                if ($Force) {
                    Write-Warning "Attempting to take ownership of the path: $Path"
                    try {
                        Start-Process -FilePath "takeown" -ArgumentList "/f `"$Path`" /r /d y" -Wait -NoNewWindow
                        Try {
                            Remove-Item -Path $Path -Recurse -Force
                        }
                        Catch {
                            Write-Error "Failed to remove files at path: $Path even after taking ownership. Error: $_"
                            Return
                        }
                        Write-Verbose "Finished removing folder: $Path after taking ownership"
                    }
                    catch {
                        Throw "Failed to remove files at path: $Path even after taking ownership. Error: $_"
                    }
                }
            }
            catch {
                Write-Error "Failed to remove files at path: $Path. Error: $_"
            }
        }
    }

    end {

    }
}

#Uses Robocopy to force overwrite a folder which has a deep structure (long file paths)

function Remove-FolderForced {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Position = 0, mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Path
    )

    Begin {
        # Validate Target Directory
        if (-not (Test-Path $Path)) {
            Throw "The target directory $Path does not exist"
        }

        #Validate that the path is not an important system directory
        if ($Path -match "Windows|Program Files|ProgramData|AppData|System32|netlogon|sysvol") {
            Write-Error "The path $Path is a system directory and cannot be removed. It is very likely you shouldn't be removing this folder."
            return
        }
    }

    Process {

        if ($PSCmdlet.ShouldProcess($Path, "Forcibly overwriting the folder using robocopy")) {

            $EmptyDir = "$env:TEMP\EmptyFolder"
            If (-not (Test-Path $EmptyDir)) {
                New-Item -Path $EmptyDir -ItemType Directory -Force
            }

            Try {
                robocopy $EmptyDir $Path /MIR | Out-Null
                Remove-Item $EmptyDir -Force
                Remove-Item $Path -Force
            }
            Catch {
                Throw "Failed to remove files at path: $Path. Error: $_"
            }

        }
    }

    End {

    }

}

function Set-AudioVolume {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Volume", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [int]$Volume,
        [Parameter(Mandatory = $true, ParameterSetName = "Mute", Position = 0)]
        [switch]$Mute
    )

    begin {
        # Validate the volume is between 0 and 100
        if ($Volume -lt 0 -or $Volume -gt 100) {
            throw "Volume must be between 0 and 100"
        }
    }

    process {
        If ($PSCmdlet.ShouldProcess("Set volume to $Volume")) {
            if ($Mute) {
                [Audio]::Mute = $true
            }
            else {
                [Audio]::Volume = $Volume / 100
                [Audio]::Mute = $false
            }
        }
    }

    end {

    }
}

#TODO: Consider changing command name
#TODO: Test multiple path input
#TODO: Add SupportsShouldProcess

<#

.SYNOPSIS
    Take or grant ownership of a file or folder.

.DESCRIPTION

    Take or grant ownership of a file or folder as the current user. Can accept Path from pipeline. Can accept multiple paths.

.PARAMETER Path

    The path(s) to the file or folder to take ownership of.

.PARAMETER Recurse

    If specified, the ownership will be applied to all files and subfolders in the specified path.

.PARAMETER Identity

    The user to take ownership as. Default is the current user.

.EXAMPLE

    Set-Ownership -Path "C:\Temp\test.txt"

    This will take ownership of the file test.txt as the current user.

.EXAMPLE

    Set-Ownership "C:\Temp" -Recurse

    This will take ownership of all files and folders in the C:\Temp directory as the current user.

.EXAMPLE

    $SomeFolder = "C:\Temp"
    $SomeFolder | Set-Ownership

    This will take ownership of the folder C:\Temp as the current user.

.EXAMPLE

    $SomeFolders = Get-ChildItem -Path "C:\Temp"
    $SomeFolders | Set-Ownership -Identity "Everyone"

    This will grant ownership of all files and folders in the C:\Temp directory to the Everyone group.

#>
function Set-Ownership {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [bool]$Recurse = $false,

        [string]$Identity = $env:USERNAME
    )

    begin {
        # Validate Path(s)
        foreach ($SinglePath in $Path) {
            if (-not (Test-Path -Path $SinglePath)) {
                Throw "Path does not exist: $SinglePath"
            }
        }
    }

    process {

        foreach ($SinglePath in $Path) {
            try {
                Write-Verbose "Taking ownership of path: $SinglePath"

                If ($PSCmdlet.ShouldProcess($SinglePath, "Set ownership to $Identity")) {
                    # Take ownership
                    $acl = Get-Acl -Path $SinglePath
                    $acl.SetOwner([System.Security.Principal.NTAccount]::new($Identity))
                    Set-Acl -Path $SinglePath -AclObject $acl

                    if ($Recurse) {
                        Try {
                            Get-ChildItem -Path $SinglePath -Recurse | ForEach-Object {
                                $acl = Get-Acl -Path $_.FullName
                                $acl.SetOwner([System.Security.Principal.NTAccount]::new($Identity))
                                Set-Acl -Path $_.FullName -AclObject $acl
                                Write-Verbose "Ownership taken successfully for path: $($_.FullName)"
                            }
                        }
                        Catch {
                            Write-Error "Failed to take ownership of path. $_"
                        }
                    }

                    # Verbose output
                    Write-Verbose "Ownership taken successfully for path: $SinglePath"
                }
                $acl = Get-Acl -Path $SinglePath
                $acl.SetOwner([System.Security.Principal.NTAccount]::new($Identity))
                Set-Acl -Path $SinglePath -AclObject $acl

                if ($Recurse) {
                    Try {
                        Get-ChildItem -Path $SinglePath -Recurse | ForEach-Object {
                            $acl = Get-Acl -Path $_.FullName
                            $acl.SetOwner([System.Security.Principal.NTAccount]::new($Identity))
                            Set-Acl -Path $_.FullName -AclObject $acl
                            Write-Verbose "Ownership taken successfully for path: $($_.FullName)"
                        }
                    }
                    Catch {
                        Write-Error "Failed to take ownership of path. $_"
                    }
                }

                # Verbose output
                Write-Verbose "Ownership taken successfully for path: $SinglePath"
            }
            catch {
                # Error handling
                Write-Error "Failed to take ownership of path: $SinglePath. $_"
            }
        }
    }

    end {
        # Cleanup code goes here
    }
}

function Stop-ProcessForced {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "ProcessName"
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "ProcessID"
        )]
        [ValidateNotNullOrEmpty()]
        [int]$ID
    )

    begin {
        # Validate the process exists
        if ($ID -and -not (Get-Process -Id $ID -ErrorAction SilentlyContinue)) {
            throw "Process with ID $ID does not exist"
        }
        elseif ($Name -and -not (Get-Process -Name $Name -ErrorAction SilentlyContinue)) {
            throw "Process with name $Name does not exist"
        }
    }

    process {

        if ($ID) {
            if ($PSCmdlet.ShouldProcess($ID, "Stop process with ID")) {
                Try {
                    TaskKill /PID $ID /F
                }
                Catch {
                    Throw "Failed to stop process with ID $($_.Id). Error: $_"
                }
            }
        }
        if ($Name) {
            If ($PSCmdlet.ShouldProcess($Name, "Stop process with name")) {
                Get-Process -Name $Name | ForEach-Object {
                    Try {
                        TaskKill /PID $_.Id /F
                    }
                    Catch {
                        Throw "Failed to stop process with ID $($_.Id). Error: $_"
                    }
                }
            }
        }
    }

    end {

    }
}

<#

.SYNOPSIS

    Tests if a folder is empty.

.DESCRIPTION

    Helper function to test if a folder is empty by checking if it contains any files or subfolders.

.PARAMETER Path

        The path of the folder to test.

.EXAMPLE

        Test-EmptyFolder -Path "C:\Temp"

        This example tests if the folder "C:\Temp" is empty.

.OUTPUTS

    True if the folder is empty, false otherwise.

#>

function Test-EmptyFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    begin {
        # Validate that the path is a folder
        if (-not (Test-Path -Path $Path -PathType Container)) {
            Throw "Path '$Path' does not exist or is not a folder."
        }
    }

    process {
        function Test-EmptyFolder($Source) {
            $items = Get-ChildItem -LiteralPath $Source -Force
            return ($items.Count -eq 0)
        }
    }

    end {

    }
}

#TODO Add alias to module manifest Uninstall-App

<#

.SYNOPSIS

    Uninstall software by name. This script will only uninstall software that is installed in the registry, not user installed software.

.DESCRIPTION

    Uninstall software by name. This script will only uninstall software that is installed in the registry, not user installed software.
    Permissions to read the registry are required to run this script. Can accept a list of apps to uninstall.

.PARAMETER SoftwareName

    The name of the software to uninstall. Can be a list of software names and accepts input from pipeline.

.PARAMETER SilentOnly

    Force the use of silent uninstall strings only.
    If a silent uninstall string does not exist then an error will be displayed and the software will not be uninstalled.

.PARAMETER KeepMinimumVersion

    Uninstall software only if it is below the minimum version number.

.EXAMPLE

    Uninstall-Software -SoftwareName "Google Chrome"

    This will uninstall Google Chrome.

.EXAMPLE

    "Google Chrome", "Mozilla Firefox" | Uninstall-Software -SilentOnly

    This will uninstall Google Chrome and Mozilla Firefox using the silent uninstall strings if they exist.

#>

function Uninstall-Software {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName, Position = 0)]
        [string[]]$Name,

        [Parameter(Mandatory = $false)]
        [switch]$SilentOnly,

        [Parameter(Mandatory = $false)]
        [Alias("minimumversion")]
        [version]$KeepMinimumVersion,

        [Parameter(Mandatory = $false)]
        [switch]$NoConfirm
    )

    begin {
        If (!(Test-IsWindowsDevice)) {
            Throw "This script can only be run on a Windows operating system."
        }
    }

    process {

        Foreach ($App in $Name) {

            Get-InstalledSoftware -SoftwareName $App | ForEach-Object {

                # Confirm uninstall
                If ($NoConfirm -eq $false) {
                    $confirm = Read-Host "Uninstall $($_.name)? (Y/N)"
                    If ($confirm -ne "Y") {
                        Write-Output "Skipping $($_.name)"
                        return
                    }
                }

                $UninstallString = $null
                [Version]$InstalledVersion = $_.Version

                # Check if the software is already at or above the minimum version
                If ($KeepMinimumVersion -and ($InstalledVersion -ge $KeepMinimumVersion)) {
                    Write-Output "$($_.name) is already at or above the minimum version of $KeepMinimumVersion."
                    $_
                    return
                }

                # Select the correct uninstall string if one exists
                If ($_.QuietUninstallString) {
                    $UninstallString = $_.QuietUninstallString
                }
                # Use the normal uninstall string if silentonly is not enabled, or if the uninstall string uses msiexec (which is silent by default)
                elseif ((-not ($SilentOnly)) -or ($_.UninstallString -match "msiexec")) {
                    $UninstallString = $_.UninstallString
                }

                # If there is still no uninstall string, write an error and move on to the next app
                if (-not ($UninstallString)) {
                    Write-Error "$($_.name) does not have a valid uninstall string."
                    return
                }

                # If the uninstallstring uses msiexec, add the /qn flag to make it silent if it's not already present
                If ($UninstallString -match "msiexec") {
                    If (-not ($UninstallString -match "/qn")) {
                        $UninstallString = "$UninstallString /qn"
                    }
                }

                Write-Output "Uninstalling $($_.name) using command: $UninstallString"

                # Uninstall the software
                if ($UninstallString -match "msiexec") {
                    $arguments = $UninstallString -replace "^msiexec.exe\s*", ""
                    Try {
                        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
                    }
                    Catch {
                        Write-Error "Failed to uninstall $($_.name). Error: $_"
                    }
                }
                else {
                    <#  Use regex to match the executable path and arguments
                        \"[^\"]+\"      A quoted string (handles paths with spaces).
                        \S+             A non-quoted string (handles paths without spaces).
                        \s*(.*)$        Any arguments that follow the executable path.
                    #>
                    if ($UninstallString -match '^(\"[^\"]+\"|\S+)\s*(.*)$') {
                        $uninstallPath = $matches[1]
                        $arguments = $matches[2]
                        Try {
                            Start-Process -FilePath $uninstallPath -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        Catch {
                            Write-Error "Failed to uninstall $($_.name). Error: $_"
                        }
                    }
                    else {
                        Write-Error "Invalid uninstall string format: $UninstallString"
                    }
                }

                # Check if the software was uninstalled
                If (-not (Get-InstalledSoftware -SoftwareName $App)) {
                    Write-Output "$($_.name) has been uninstalled:"
                    $_
                }
                else {
                    Write-Error "$($_.name) was not uninstalled. Ensure you are running with sufficient permissions to uninstall it. Alternatively, a reboot may be required to complete the uninstallation."
                    $_
                }
            }
        }
    }

    end {

    }
}

# https://itpro-tips.com/2020/update-all-powershell-modules-at-once/
# https://itpro-tips.com/2020/mettre-a-jour-tous-les-modules-powershell-en-une-fois/
Function Update-AllPowershellModules.ps1 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "This function does not change system state.")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Write-Host is used to display information to the user.")]
    [CmdletBinding()]
    param (
        [Parameter()]
        # To exclude modules from the update process
        [String[]]$ExcludedModules,
        # To include only these modules for the update process
        [String[]]$IncludedModules,
        [switch]$SkipPublisherCheck,
        [switch]$SimulationMode
    )
    <#
/!\/!\/!\ PLEASE READ /!\/!\/!\
/!\     If you look for a quick way to update, please keep in mind Microsoft has a built-in CMDlzt to update ALL the PowerShell modules installed:
/!\     Update-Module [-Verbose]
/!\     This script is intended as a replacement of the Update-Module:
/!\     - to provide more human readable output than the -Verbose option of Update-Module
/!\     - to force install with -SkipPublisherCheck (Authenticode change) because Update-Module has not this option
/!\     - to exclude some modules from the update process
/!\     - to remove older versions because Update-Module does not remove older versions (it only installs a new version in the $env:PSModulePath\<moduleName> and keep the old module)
This script provides informations about the module version (current and the latest available on PowerShell Gallery) and update to the latest version
If you have a module with two or more versions, the script delete them and reinstall only the latest.
#>

    #Requires -Version 5.0
    #Requires -RunAsAdministrator

    Write-Host -ForegroundColor cyan 'Define PowerShell to add TLS1.2 in this session, needed since 1st April 2020 (https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/)'
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    # if needed, register PSGallery
    # Register PSGallery PSprovider and set as Trusted source
    # Register-PSRepository -Default -ErrorAction SilentlyContinue
    # Set-PSRepository -Name PSGallery -InstallationPolicy trusted -ErrorAction SilentlyContinue

    if ($SimulationMode) {
        Write-Host -ForegroundColor yellow 'Simulation mode is ON, nothing will be installed / removed / updated'
    }

    Write-Host -ForegroundColor Cyan 'Get all PowerShell modules'

    function Remove-OldPowerShellModules {
        param (
            [string]$ModuleName,
            [string]$GalleryVersion
        )

        try {
            $oldVersions = Get-InstalledModule -Name $ModuleName -AllVersions -ErrorAction Stop | Where-Object { $_.Version -ne $GalleryVersion }

            foreach ($oldVersion in $oldVersions) {
                Write-Host -ForegroundColor Cyan "$ModuleName - Uninstall previous version ($($oldVersion.Version))"
                if (-not($SimulationMode)) {
                    Remove-Module $ModuleName -ErrorAction SilentlyContinue
                    Uninstall-Module $oldVersion -Force -ErrorAction Stop
                }
            }
        }
        catch {
            Write-Warning "$module - $($_.Exception.Message)"
        }
    }

    if ($IncludedModules) {
        $modules = Get-InstalledModule | Where-Object { $IncludedModules -contains $_.Name }
    }
    else {
        $modules = Get-InstalledModule
    }

    foreach ($module in $modules.Name) {
        if ($ExcludedModules -contains $module) {
            Write-Host -ForegroundColor Yellow "Module $module is excluded from the update process"
            continue
        }
        elseif ($module -like "$excludedModules") {
            Write-Host -ForegroundColor Yellow "Module $module is excluded from the update process (match $excludeModules)"
            continue
        }

        $currentVersion = $null

        try {
            $currentVersion = (Get-InstalledModule -Name $module -AllVersions -ErrorAction Stop).Version
        }
        catch {
            Write-Warning "$module - $($_.Exception.Message)"
            continue
        }

        try {
            $moduleGalleryInfo = Find-Module -Name $module -ErrorAction Stop
        }
        catch {
            Write-Warning "$module not found in the PowerShell Gallery. $($_.Exception.Message)"
        }

        if ($null -eq $currentVersion) {
            Write-Host -ForegroundColor Cyan "$module - Install from PowerShellGallery version $($moduleGalleryInfo.Version) - Release date: $($moduleGalleryInfo.PublishedDate)"

            if (-not($SimulationMode)) {
                try {
                    Install-Module -Name $module -Force -SkipPublisherCheck -ErrorAction Stop
                }
                catch {
                    Write-Warning "$module - $($_.Exception.Message)"
                }
            }
        }
        elseif ($moduleGalleryInfo.Version -eq $currentVersion) {
            Write-Host -ForegroundColor Green "$module already in latest version: $currentVersion - Release date: $($moduleGalleryInfo.PublishedDate)"
        }
        elseif ($currentVersion.count -gt 1) {
            Write-Host -ForegroundColor Yellow "$module is installed in $($currentVersion.count) versions (versions: $($currentVersion -join ' | '))"
            Write-Host -ForegroundColor Cyan "$module - Uninstall previous $module version(s) below the latest version ($($moduleGalleryInfo.Version))"

            Remove-OldPowerShellModules -ModuleName $module -GalleryVersion $moduleGalleryInfo.Version

            # Check again the current Version as we uninstalled some old versions
            $currentVersion = (Get-InstalledModule -Name $module).Version

            if ($moduleGalleryInfo.Version -ne $currentVersion) {
                Write-Host -ForegroundColor Cyan "$module - Install from PowerShellGallery version $($moduleGalleryInfo.Version) - Release date: $($moduleGalleryInfo.PublishedDate)"
                if (-not($SimulationMode)) {
                    try {
                        Install-Module -Name $module -Force -ErrorAction Stop

                        Remove-OldPowerShellModules -ModuleName $module -GalleryVersion $moduleGalleryInfo.Version
                    }
                    catch {
                        Write-Warning "$module - $($_.Exception.Message)"
                    }
                }
            }
        }
        # https://invoke-thebrain.com/2018/12/comparing-version-numbers-powershell/
        elseif ([version]$currentVersion -gt [version]$moduleGalleryInfo.Version) {
            Write-Host -ForegroundColor Yellow "$module - the current version $currentVersion is newer than the version available on PowerShell Gallery $($moduleGalleryInfo.Version) (Release date: $($moduleGalleryInfo.PublishedDate)). Sometimes happens when you install a module from another repository or via .exe/.msi or if you change the version number manually."
        }
        elseif ([version]$currentVersion -lt [version]$moduleGalleryInfo.Version) {
            Write-Host -ForegroundColor Cyan "$module - Update from PowerShellGallery version " -NoNewline
            Write-Host -ForegroundColor White "$currentVersion -> $($moduleGalleryInfo.Version) " -NoNewline
            Write-Host -ForegroundColor Cyan "- Release date: $($moduleGalleryInfo.PublishedDate)"

            if (-not($SimulationMode)) {
                try {
                    Update-Module -Name $module -Force -ErrorAction Stop
                    Remove-OldPowerShellModules -ModuleName $module -GalleryVersion $moduleGalleryInfo.Version
                }
                catch {
                    if ($_.Exception.Message -match 'Authenticode') {
                        Write-Host -ForegroundColor Yellow "$module - The module certificate used by the creator is either changed since the last module install or the module sign status has changed."

                        if ($SkipPublisherCheck.IsPresent) {
                            Write-Host -ForegroundColor Cyan "$module - SkipPublisherCheck Parameter is present, so install will run without Authenticode check"
                            Write-Host -ForegroundColor Cyan "$module - Install from PowerShellGallery version $($moduleGalleryInfo.Version) - Release date: $($moduleGalleryInfo.PublishedDate)"
                            try {
                                Install-Module -Name $module -Force -SkipPublisherCheck
                            }
                            catch {
                                Write-Warning "$module - $($_.Exception.Message)"
                            }

                            Remove-OldPowerShellModules -ModuleName $module -GalleryVersion $moduleGalleryInfo.Version
                        }
                        else {
                            Write-Warning "$module - If you want to update this module, run again with -SkipPublisherCheck switch, but please keep in mind the security risk"
                        }
                    }
                    else {
                        Write-Warning "$module - $($_.Exception.Message)"
                    }
                }
            }
        }
    }
}

# This is used to control the audio volume of the computer.

Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume
{
    // f(), g(), ... are unused COM method slots. Define these if you care
    int f(); int g(); int h(); int i();
    int SetMasterVolumeLevelScalar(float fLevel, System.Guid pguidEventContext);
    int j();
    int GetMasterVolumeLevelScalar(out float pfLevel);
    int k(); int l(); int m(); int n();
    int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, System.Guid pguidEventContext);
    int GetMute(out bool pbMute);
}
[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice
{
    int Activate(ref System.Guid id, int clsCtx, int activationParams, out IAudioEndpointVolume aev);
}
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator
{
    int f(); // Unused
    int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
}
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }
public class Audio
{
    static IAudioEndpointVolume Vol()
    {
        var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
        IMMDevice dev = null;
        Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(/*eRender*/ 0, /*eMultimedia*/ 1, out dev));
        IAudioEndpointVolume epv = null;
        var epvid = typeof(IAudioEndpointVolume).GUID;
        Marshal.ThrowExceptionForHR(dev.Activate(ref epvid, /*CLSCTX_ALL*/ 23, 0, out epv));
        return epv;
    }
    public static float Volume
    {
        get { float v = -1; Marshal.ThrowExceptionForHR(Vol().GetMasterVolumeLevelScalar(out v)); return v; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMasterVolumeLevelScalar(value, System.Guid.Empty)); }
    }
    public static bool Mute
    {
        get { bool mute; Marshal.ThrowExceptionForHR(Vol().GetMute(out mute)); return mute; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMute(value, System.Guid.Empty)); }
    }
}
'@

<#
.SYNOPSIS
    Finds the longest common prefix string amongst an array of strings.

.DESCRIPTION
    This function takes an array of strings and determines the longest common prefix shared among them.
    It iterates through each string and compares characters to find the common prefix.
    Useful for finding the common prefix of file paths or similar strings.

.PARAMETER Strings
    An array of strings for which the longest common prefix is to be found.
    If a single string is passed, the whole string will be returned.

.EXAMPLE
    $result = Get-LongestCommonPrefix -Strings @("flower", "flow", "flight")
    Write-Output $result
    # Output: "fl"

.NOTES
    The function assumes that the input array contains at least one string.
    If the array is empty, the function will throw an error.

#>
function Get-LongestCommonPrefix {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$Strings
    )

    # Initialize the minimum length to the length of the first string
    $MinLength = $Strings[0].Length

    # Iterate through each string in the array starting from the second string
    for ($i = 1; $i -lt $Strings.Length; $i++) {

        # Update the minimum length to the smallest length found so far
        $MinLength = [Math]::Min($MinLength, $Strings[$i].Length)

        # Compare characters of the current string with the first string up to the minimum length
        for ($j = 0; $j -lt $MinLength; $j++) {

            # If characters do not match, update the minimum length to the current position and finish
            if ($Strings[$i][$j] -ne $Strings[0][$j]) {
                $MinLength = $j
                break
            }
        }
    }

    # Return the common prefix found in the first string up to the minimum length
    return $Strings[0].Substring(0, $MinLength)
}



function New-Credential {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "This function does not change system state.")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Password
    )

    begin {
        $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    }

    process {
        $Credential = [PSCredential]::New($Username, $SecurePassword)
        Return $Credential
    }

    end {

    }
}


