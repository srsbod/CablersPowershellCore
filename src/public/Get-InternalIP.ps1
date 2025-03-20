<#
.SYNOPSIS
    Retrieves internal IP addresses and network adapter details.

.DESCRIPTION
    This function retrieves internal IP addresses and network adapter details for all active network interfaces.
    It includes information such as adapter name, description, IP address, subnet mask, gateway, and DNS servers.

.OUTPUTS
    PSCustomObject
    Returns a custom object containing network adapter details.

.EXAMPLE
    Get-InternalIP
    Retrieves internal IP addresses and details for all active network adapters.

#>
Function Get-InternalIP {
    [CmdletBinding()]
    param (

    )

    Begin {
        $adapters = @()
    }

    Process {

        $ipv4Config = Get-NetIPConfiguration | Where-Object { $null -ne $_.IPv4Address }

        Foreach ($adapter in $ipv4Config) {
        
            If ($Adapter.InterfaceAlias -eq "vEthernet (Default Switch)") {
                continue
            }
            If ($adapter.NetAdapter.Status -ne "Up") {
                $adapters += [PSCustomObject]@{
                    Adapter     = $Adapter.InterfaceAlias
                    Description = $Adapter.InterfaceDescription
                    Status      = $Adapter.NetAdapter.Status
                }
            }
            else {

                $adapters += [PSCustomObject]@{
                    Adapter         = $Adapter.InterfaceAlias
                    Description     = $Adapter.InterfaceDescription
                    IPv4Address     = $Adapter.IPv4Address.IPAddress
                    SubnetMask      = Convert-PrefixToSubnetMask ($Adapter.IPv4Address.prefixLength)
                    Gateway         = $Adapter.IPv4DefaultGateway.NextHop
                    DnsServers      = $Adapter.DnsServer.ServerAddresses
                    PrefixLength    = $Adapter.IPv4Address.PrefixLength
                    IPConfiguration = $Adapter.IPv4Address.PrefixOrigin
                    Status          = "Up"
                }
            }
        }

        Write-Output $adapters

    }

    End {

    }
}
