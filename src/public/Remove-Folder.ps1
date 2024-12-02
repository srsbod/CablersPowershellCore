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
