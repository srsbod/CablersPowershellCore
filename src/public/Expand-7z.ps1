#TODO: Comment based help
#TODO: Test

Function Expand-7z {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SourceFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationFolder,
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    Begin {
        #Validate the source file
        if (-not (Test-Path -Path $SourceFile -ErrorAction SilentlyContinue)) {
            Throw "Source file at path $SourceFile does not exist"
        }
        #Validate the destination folder
        if (-not (Test-Path -Path $DestinationFolder -ErrorAction SilentlyContinue)) {
            Throw "Destination folder at path $DestinationFolder does not exist"
        }
        #Check 7z command exists
        if (-not (Get-Command -Name "7z" -ErrorAction SilentlyContinue)) {
            Throw "7z not found in the PATH. Make sure it is installed."
        }
    }

    Process {
        #Extract the 7z file
        $arguments = "x $SourceFile -o $DestinationFolder"
        if ($Force) {
            $arguments += " -y"
        }
        Try {
            Start-Process -FilePath "7z" -ArgumentList $arguments -Wait -NoNewWindow -PassThru
        }
        Catch {
            Throw "Failed to extract $SourceFile to $DestinationFolder - $_"
        }
    }

    End {

    }
}

