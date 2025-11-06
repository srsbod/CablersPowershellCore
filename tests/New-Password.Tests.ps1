Describe 'New-Password' {
    Context 'When generating a password' {
        It 'Should return a password when -Simple is specified' {
            $result = New-Password -Simple
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Match '[0-9]' -Because 'Simple password should contain numbers'
            $result | Should -Match '[a-z]' -Because 'Simple password should contain lower case letters'
            $result | Should -Not -Match '[!@#$%^&*(),.?":{}|<>]' -Because 'Simple password should not contain special characters'

        }

        It 'Should return a password when -Strong is specified' {
            $result = New-Password -Strong
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Match '[0-9]' -Because 'Strong password should contain numbers'
            $result | Should -Match '[A-Z]' -Because 'Strong password should contain upper case letters'
            $result | Should -Match '[a-z]' -Because 'Strong password should contain lower case letters'
            $result | Should -Match '[!@#$%^&*(),.?":{}|<>]' -Because 'Strong password should contain special characters'
        }

        It 'Should return a password of the specified length when -Random is used' {
            $length = 16
            $result = New-Password -Random -Length $length
            $result.Length | Should -Be $length
        }

        It 'Should generate the specified number of passwords' {
            $count = 5
            $result = New-Password -Simple -NumberOfPasswords $count
            $result.Count | Should -Be $count
        }

        It 'Should generate passwords without symbols when -NoSymbols is specified' {
            $result = New-Password -Random -Length 12 -NoSymbols
            $result | Should -Not -Match '[!@#$%^&*(),.?":{}|<>]' -Because 'Passwords without symbols should not contain special characters'
        }

        It 'Should generate passwords with symbols when -NoSymbols is not specified' {
            $result = New-Password -Random -Length 12
            $result | Should -Match '[!@#$%^&*(),.?":{}|<>]' -Because 'Passwords with symbols should contain special characters'
        }

        It 'Should generate unique passwords when multiple are requested' {
            $count = 10
            $result = New-Password -Strong -NumberOfPasswords $count
            ($result | Sort-Object | Get-Unique).Count | Should -Be $count -Because 'Generated passwords should be unique'
        }
    }
}


