<#
.SYNOPSIS
    Compresses files or folders into a .7z archive.

.DESCRIPTION
    This function uses the 7z command-line tool to compress files or folders into a .7z archive.
    Optionally, it can delete the original files or folders after compression.

.PARAMETER SourcePath
    The path to the file or folder to compress.

.PARAMETER ArchivePath
    The path where the .7z archive will be created. If not specified, the archive will be created in the same directory as the source.

.PARAMETER DeleteOriginal
    Deletes the original file or folder after compression.

.EXAMPLE
    Compress-7z -SourcePath "C:\Temp\File.txt"
    Compresses the file into a .7z archive in the same directory.

.EXAMPLE
    Compress-7z -SourcePath "C:\Temp\Folder" -ArchivePath "C:\Archives\Folder.7z"
    Compresses the folder into the specified archive path.

.EXAMPLE
    Compress-7z -SourcePath "C:\Temp\File.txt" -DeleteOriginal
    Compresses the file and deletes the original.

#>
function Compress-7z {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,
        [Parameter(Mandatory = $false)]
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

        # Validate the archive path if it was specified
        if ($ArchivePath -and (Test-Path -Path $ArchivePath -ErrorAction SilentlyContinue)) {
            Throw "Archive path at $ArchivePath already exists. Please specify a different path."
        }

        # If ArchivePath is not specified, create it in the same folder as the source
        if (-not $ArchivePath) {
            $SourceFullPath = Resolve-Path -Path $SourcePath
            $ArchivePath = Join-Path -Path (Split-Path -Path $SourceFullPath -Parent) -ChildPath ((Split-Path -Path $SourceFullPath -Leaf) + ".7z")
        }

        # Check 7z command exists
        if (-not (Get-Command -Name "7z" -ErrorAction SilentlyContinue)) {
            Throw "7z not found in the PATH. Make sure it is installed."
        }
    }

    process {
        # Compress the 7z file
        $arguments = "a `"$ArchivePath`" `"$SourcePath`""
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


