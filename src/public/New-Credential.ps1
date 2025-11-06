
function New-Credential {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "This function does not change system state.")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Password
    )

    begin {
        $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    }

    process {
        $Credential = [PSCredential]::New($Username, $SecurePassword)
        Write-Output $Credential
    }

    end {

    }
}


