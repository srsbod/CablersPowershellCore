Describe 'Get-InternalIP' {
    Context 'When retrieving internal IP addresses' {
        It 'Should return a list of adapters with valid properties' {
            $result = Get-InternalIP
            $result | Should -Not -BeNullOrEmpty
            foreach ($adapter in $result) {
                $adapter.PSObject.Properties.Name | Should -Contain 'Adapter'
                $adapter.PSObject.Properties.Name | Should -Contain 'Description'
                $adapter.PSObject.Properties.Name | Should -Contain 'Status'
                If ($adapter.status -eq "Up") {
                    $adapter.PSObject.Properties.Name | Should -Contain 'IPv4Address'
                    $adapter.PSObject.Properties.Name | Should -Contain 'SubnetMask'
                    $adapter.PSObject.Properties.Name | Should -Contain 'Gateway'
                    $adapter.PSObject.Properties.Name | Should -Contain 'DnsServers'
                    $adapter.PSObject.Properties.Name | Should -Contain 'PrefixLength'
                    $adapter.PSObject.Properties.Name | Should -Contain 'IPConfiguration'
                }
            }
        }
    }
}


