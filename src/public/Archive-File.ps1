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
