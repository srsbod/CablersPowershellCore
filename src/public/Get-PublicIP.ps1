(curl icanhazip.com).Content | clip

function Get-PublicIP {
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

        Return $PublicIP
    }

    end {

    }
}
