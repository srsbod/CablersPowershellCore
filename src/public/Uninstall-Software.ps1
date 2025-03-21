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
    }

    process {
        foreach ($App in $Name) {
            $installedSoftware = Get-InstalledSoftware -SoftwareName $App

            if (-not $installedSoftware) {
                Write-Warning "$App is not installed."
                continue
            }

            foreach ($software in $installedSoftware) {
                # Confirm uninstall
                if (-not $NoConfirm) {
                    $confirm = Read-Host "Uninstall $($software.name)? (Y/N)"
                    if ($confirm -ne "Y") {
                        Write-Output "Skipping $($software.name)"
                        continue
                    }
                }

                $UninstallString = $null
                [Version]$InstalledVersion = $software.Version

                # Check if the software is already at or above the minimum version
                if ($KeepMinimumVersion -and ($InstalledVersion -ge $KeepMinimumVersion)) {
                    Write-Output "$($software.name) is already at or above the minimum version of $KeepMinimumVersion."
                    continue
                }

                # Select the correct uninstall string if one exists
                if ($software.QuietUninstallString) {
                    $UninstallString = $software.QuietUninstallString
                }
                elseif ((-not $SilentOnly) -or ($software.UninstallString -match "msiexec")) {
                    $UninstallString = $software.UninstallString
                }

                # If there is still no uninstall string, write an error and move on to the next app
                if (-not $UninstallString) {
                    Write-Error "$($software.name) does not have a valid uninstall string."
                    continue
                }

                # If the uninstall string uses msiexec, add the /qn flag to make it silent if it's not already present
                if ($UninstallString -match "msiexec") {
                    if (-not ($UninstallString -match "/qn")) {
                        $UninstallString = "$UninstallString /qn"
                    }
                }

                Write-Output "Uninstalling $($software.name) using command: $UninstallString"

                # Uninstall the software
                if ($UninstallString -match "msiexec") {
                    $arguments = $UninstallString -replace "^msiexec.exe\s*", ""
                    try {
                        Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
                    }
                    catch {
                        Write-Error "Failed to uninstall $($software.name). Error: $_"
                    }
                }
                else {
                    if ($UninstallString -match '^(\"[^\"]+\"|\S+)\s*(.*)$') {
                        $uninstallPath = $matches[1]
                        $arguments = $matches[2]
                        try {
                            Start-Process -FilePath $uninstallPath -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        catch {
                            Write-Error "Failed to uninstall $($software.name). Error: $_"
                        }
                    }
                    else {
                        Write-Error "Invalid uninstall string format: $UninstallString"
                    }
                }

                # Check if the software was uninstalled
                if (-not (Get-InstalledSoftware -SoftwareName $App)) {
                    Write-Output "$($software.name) has been uninstalled."
                }
                else {
                    Write-Error "$($software.name) was not uninstalled. Ensure you are running with sufficient permissions to uninstall it. Alternatively, a reboot may be required to complete the uninstallation."
                }
            }
        }
    }

    end {
    }
}
