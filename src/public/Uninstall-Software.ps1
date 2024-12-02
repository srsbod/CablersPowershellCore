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
