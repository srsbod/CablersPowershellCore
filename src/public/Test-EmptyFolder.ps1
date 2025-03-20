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
        $items = Get-ChildItem -LiteralPath $Path -Force
        return ($items.Count -eq 0)
    }

    end {

    }
}
