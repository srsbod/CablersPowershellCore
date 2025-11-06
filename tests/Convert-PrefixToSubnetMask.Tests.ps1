Describe 'Convert-PrefixToSubnetMask' {
    BeforeAll {
        # Import the module or function if necessary
        # Import-Module -Name 'CablersPowershellCore'
    }

    Context 'Valid Prefix Lengths' {
        It 'Should return the correct subnet mask for prefix length 24' {
            Convert-PrefixToSubnetMask -prefixLength 24 | Should -Be '255.255.255.0'
        }

        It 'Should return the correct subnet mask for prefix length 16' {
            Convert-PrefixToSubnetMask -prefixLength 16 | Should -Be '255.255.0.0'
        }

        It 'Should return the correct subnet mask for prefix length 8' {
            Convert-PrefixToSubnetMask -prefixLength 8 | Should -Be '255.0.0.0'
        }

        It 'Should return the correct subnet mask for prefix length 32' {
            Convert-PrefixToSubnetMask -prefixLength 32 | Should -Be '255.255.255.255'
        }
    }

    Context 'Invalid Prefix Lengths' {
        It 'Should throw an error for prefix length 0' {
            { Convert-PrefixToSubnetMask -prefixLength 0 } | Should -Throw
        }

        It 'Should throw an error for prefix length 33' {
            { Convert-PrefixToSubnetMask -prefixLength 33 } | Should -Throw
        }
    }

    Context 'Edge Cases' {
        It 'Should return the correct subnet mask for prefix length 1' {
            Convert-PrefixToSubnetMask -prefixLength 1 | Should -Be '128.0.0.0'
        }

        It 'Should return the correct subnet mask for prefix length 31' {
            Convert-PrefixToSubnetMask -prefixLength 31 | Should -Be '255.255.255.254'
        }
    }
}


