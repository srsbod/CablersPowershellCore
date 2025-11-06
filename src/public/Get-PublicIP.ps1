function Get-PublicIP {
    <#
    .SYNOPSIS
    Retrieves the public IP address of the machine.

    .DESCRIPTION
    The Get-PublicIP function uses an external service to fetch the public IP address of the machine.
    Optionally, it can copy the IP address to the clipboard.

    .SYNTAX
    Get-PublicIP [[-CopyToClipboard] [<SwitchParameter>]]

    .PARAMETER CopyToClipboard
    If specified, the public IP address will be copied to the clipboard.

    .OUTPUTS
    System.String
    The public IP address.

    .EXAMPLE
    PS C:\> Get-PublicIP
    203.0.113.42

    .EXAMPLE
    PS C:\> Get-PublicIP -CopyToClipboard
    203.0.113.42
    The IP address is copied to the clipboard.

    .NOTES
    Author: Bradley Bullock

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$CopyToClipboard
    )

    begin {

    }

    process {
        $PublicIP = (Invoke-RestMethod -Uri "https://icanhazip.com").Trim()

        If ($CopyToClipboard) {
            $PublicIP | Set-Clipboard
        }

        Write-Output $PublicIP
    }

    end {

    }
}


