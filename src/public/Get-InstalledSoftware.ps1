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
