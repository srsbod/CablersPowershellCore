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
