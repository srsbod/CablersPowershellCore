#Uses Robocopy to force overwrite a folder which has a deep structure (long file paths)

function Remove-FolderForced {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Position = 0, mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Path
    )

    Begin {
        # Validate Target Directory
        if (-not (Test-Path $Path)) {
            Throw "The target directory $Path does not exist"
        }

        #Validate that the path is not an important system directory
        if ($Path -match "Windows|Program Files|ProgramData|AppData|System32|netlogon|sysvol") {
            Write-Error "The path $Path is a system directory and cannot be removed. It is very likely you shouldn't be removing this folder."
            return
        }
    }

    Process {

        if ($PSCmdlet.ShouldProcess($Path, "Forcibly overwriting the folder using robocopy")) {

            $EmptyDir = "$env:TEMP\EmptyFolder"
            If (-not (Test-Path $EmptyDir)) {
                New-Item -Path $EmptyDir -ItemType Directory -Force
            }

            Try {
                robocopy $EmptyDir $Path /MIR | Out-Null
                Remove-Item $EmptyDir -Force
                Remove-Item $Path -Force
            }
            Catch {
                Throw "Failed to remove files at path: $Path. Error: $_"
            }

        }
    }

    End {

    }

}
