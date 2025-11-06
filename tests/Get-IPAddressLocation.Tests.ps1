Describe 'Get-IPAddressLocation' {
    Context 'When retrieving location for valid IP addresses' {
        It 'Should return location details for a single valid IP address' {
            Mock -CommandName Invoke-RestMethod -MockWith {
                [PSCustomObject]@{
                    country_name  = "United States"
                    country_code2 = "US"
                    isp           = "Google LLC"
                }
            }
            $result = Get-IPAddressLocation -IPAddress "8.8.8.8"
            $result.IPAddress | Should -Be "8.8.8.8"
            $result.Country | Should -Be "United States"
            $result.CountryCode | Should -Be "US"
            $result.ISP | Should -Be "Google LLC"
        }

        It 'Should return location details for multiple valid IP addresses' {
            Mock -CommandName Invoke-RestMethod -MockWith {
                [PSCustomObject]@{
                    country_name  = "United States"
                    country_code2 = "US"
                    isp           = "Google LLC"
                }
            }
            $result = Get-IPAddressLocation -IPAddress @("8.8.8.8", "1.1.1.1")
            $result.Count | Should -Be 2
        }
    }

    Context 'When handling only invalid IP Addresses' {
        It 'Should return null' {
            $result = Get-IPAddressLocation -IPAddress "999.999.999.999"
            $result | Should -Be $null
        }
    }

    Context 'When handling mixed valid and invalid IP addresses' {
        It 'Should return information for valid IPs and ignore invalid IPs' {
            Mock -CommandName Invoke-RestMethod -MockWith {
                param ($Uri)
                if ($Uri -like "*8.8.8.8*") {
                    [PSCustomObject]@{
                        country_name  = "United States"
                        country_code2 = "US"
                        isp           = "Google LLC"
                    }
                }
                elseif ($Uri -like "*999.999.999.999*") {
                    throw "Invalid IP address"
                }
            }
            $result = Get-IPAddressLocation -IPAddress @("8.8.8.8", "999.999.999.999")
            $result.Count | Should -Be 1
            $result[0].IPAddress | Should -Be "8.8.8.8"
            $result[0].Country | Should -Be "United States"
            $result[0].CountryCode | Should -Be "US"
            $result[0].ISP | Should -Be "Google LLC"
        }
    }
}


