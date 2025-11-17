<#

.SYNOPSIS

    Tests if a folder is empty.

.DESCRIPTION

    Helper function to test if a folder is empty by checking if it contains any files or subfolders.
    If no path is specified, tests the current directory.

.PARAMETER Path

    The path of the folder to test. Defaults to the current directory if not specified.
    Accepts input from the pipeline.

.EXAMPLE

    Test-EmptyFolder -Path "C:\Temp"

    This example tests if the folder "C:\Temp" is empty.

.EXAMPLE

    Test-EmptyFolder

    This example tests if the current directory is empty.

.EXAMPLE

    "C:\Temp", "C:\Logs" | Test-EmptyFolder

    This example tests if multiple folders are empty using pipeline input.

.EXAMPLE

    Get-ChildItem -Directory | Test-EmptyFolder

    This example tests all subdirectories in the current directory.

.OUTPUTS

    True if the folder is empty, false otherwise.

#>

function Test-EmptyFolder {
    [CmdletBinding()]
    [Alias('isempty')]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [string]$Path = (Get-Location).Path
    )

    begin {
    }

    process {
        # Validate that the path is a folder
        if (-not (Test-Path -Path $Path -PathType Container)) {
            Throw "Path '$Path' does not exist or is not a folder."
        }

        $items = Get-ChildItem -LiteralPath $Path -Force
        $isEmpty = ($items.Count -eq 0)
        Write-Output $isEmpty
    }

    end {

    }
}


