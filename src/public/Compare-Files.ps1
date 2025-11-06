# Compare two files to see if they are the same using Get-FileHash

Function Compare-Files {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SourceFile,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$ComparisonFile
    )

    Begin {

        # Validate the files exist
        If (-not (Test-Path $SourceFile)) {
            Throw "File at path $SourceFile does not exist"
        }
        If (-not (Test-Path $ComparisonFile)) {
            Throw "File at path $ComparisonFile does not exist"
        }
    }

    Process {

        $SourceHash = (Get-FileHash $SourceFile).Hash
        $ComparisonHash = (Get-FileHash $ComparisonFile).Hash

        $Object = [PSCustomObject]@{
            Match              = $true
            SourceFileHash     = $SourceHash
            ComparisonFileHash = $ComparisonHash
        }

        If ($SourceHash -eq $ComparisonHash) {
            Write-Output "Files are the same"
            $Object.Match = $True
        }
        Else {
            Write-Output "Files are different"
            $Object.Match = $False
        }

        Write-Output $Object
    }

    End {

    }
}


