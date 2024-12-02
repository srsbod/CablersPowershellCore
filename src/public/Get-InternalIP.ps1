#TODO: Comment based help
#TODO: Error handling?

Function Get-InternalIP {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Interface,
        [Parameter(Mandatory = $false)]
        [Switch]$ValidInternalNetwork # Only return interfaces with a 192 or 10 address
    )

    Begin {

    }

    Process {
        $AllInterfaces = Get-NetIPAddress -AddressFamily IPv4
        $MatchedInterfaces = $AllInterfaces | Where-Object { $_.InterfaceAlias -Match $Interface }
        If ($ValidInternalNetwork) {
            $MatchedInterfaces = $MatchedInterfaces | Where-Object { $_.IPAddress -Match "^(192|10)\." }
        }
        Return ($MatchedInterfaces | Select-Object IPAddress, InterfaceAlias, InterfaceIndex, PrefixLength, PrefixOrigin, AddressState)
    }

    End {

    }
}
