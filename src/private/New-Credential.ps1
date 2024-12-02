
function New-Credential {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "This function does not change system state.")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Password
    )

    begin {
        $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    }

    process {
        $Credential = [PSCredential]::New($Username, $SecurePassword)
        Return $Credential
    }

    end {

    }
}
