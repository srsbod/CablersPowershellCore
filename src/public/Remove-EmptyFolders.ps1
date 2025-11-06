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
            $RemovedFolders += Remove-EmptyFolders $folder.FullName
        }

        # Check if the current folder is empty remove it
        if (Test-EmptyFolder $Path) {
            Try {
                if ($PSCmdlet.ShouldProcess($Path, "Remove-EmptyFolder")) {
                    Remove-Item -Path $Path -Verbose:$VerbosePreference
                    $RemovedFolders += $Path
                }
            }
            Catch {
                Write-Warning "Failed to remove folder $Path. Error: $_"
            }
        }

        Write-Output $RemovedFolders
    }

    end {

    }
}


