<#
.SYNOPSIS
    Get the geographical location of an IP address using the iplocation.net API.

.DESCRIPTION
    Get the geographical location of an IP address using the iplocation.net API.
    Returns an object containing the IP address, country, country code, and ISP.

.SYNTAX
    Get-IPAddressLocation [-IPAddress] <string[]> [<CommonParameters>]

.PARAMETER IPAddress
    The IP address(es) to retrieve location information for. Accepts input from pipeline. Accepts multiple IP Addresses.

.EXAMPLE
    Get-IPAddressLocation -IPAddress "8.8.8.8"
    This will retrieve the location information for the IP address

.EXAMPLE
    $IPAddresses = "1.1.1.1", "8.8.8.8"
    $IPAddresses | Get-IPAddressLocation
    This will retrieve the location information for the IP addresses

#>
function Get-IPAddressLocation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$IPAddress
    )
    process {

        $results = @()

        $totalIPs = $IPAddress.Count
        $currentProgress = 0

        foreach ($IP in $IPAddress) {

            $currentProgress++
            $statusMessage = "Processing IP address: $IP"
            $percentComplete = ($currentProgress / $totalIPs) * 100
            Write-Progress -Activity "Retrieving IP Address Locations" -Status $statusMessage -PercentComplete $percentComplete

            Write-Verbose "Processing IP address: $IP"
            Try {
                # Parse the IP to confirm it's valid, this is more reliable than just casting it straight to an IP address object
                $validatedIP = [ipaddress]::Parse($IP)
                Write-Verbose "Successfully validated IP address format for $IP."
                Write-Debug "IP address $IP has been parsed as $validatedIP."
            }
            Catch {
                Write-Warning "The specified IP Address $IP is not valid."
                continue
            }

            Write-Verbose "Retrieving location information for IP address: $validatedIP."
            Try {

                $response = Invoke-RestMethod -Uri "https://api.iplocation.net/?ip=$validatedIP" -Method Get
                Write-Verbose "Successfully retrieved location information for IP address: $validatedIP."
                Write-Debug "Response received: $($response | Out-String)"

                #Build
                $result = [PSCustomObject]@{
                    IPAddress   = $validatedIP.ToString()
                    Country     = $response.country_name
                    CountryCode = $response.country_code2
                    ISP         = $response.isp
                }

                $results += $result

            }
            Catch {
                if ($_.Exception.Response.StatusCode -eq "400") {
                    Write-Error "Bad Request: An error occurred while retrieving IP Address location information for ${IP}."
                }
                elseif ($_.Exception.Response.StatusCode -eq "401") {
                    Write-Error "Unauthorized: An error occurred while retrieving IP Address location information for ${IP}."
                }
                elseif ($_.Exception.Response.StatusCode -eq "403") {
                    Write-Error "Forbidden: An error occurred while retrieving IP Address location information for ${IP}."
                }
                elseif ($_.Exception.Response.StatusCode -eq "404") {
                    Write-Error "Not Found: An error occurred while retrieving IP Address location information for ${IP}."
                }
                else {
                    Write-Error "An error occurred while retrieving IP Address location information for ${IP}: $_"
                }
            }
            Write-Debug "Initiating a 500ms delay for rate limiting purposes."
            Start-Sleep -Milliseconds 500
        }

        Write-Progress -Activity "Retrieving IP Address Locations" -Status "Completed" -Completed

        Write-Verbose "Completed processing all IP addresses."
        return $results

    }
}
