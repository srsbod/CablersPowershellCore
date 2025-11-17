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

    Context 'When outputting passwords to a file' {
        BeforeEach {
            $testFile = Join-Path $TestDrive "passwords.txt"
        }

        It 'Should write passwords to file and return success message instead of passwords' {
            $count = 3
            $result = New-Password -Simple -NumberOfPasswords $count -OutputPath $testFile -NoProgress
            
            # Result should be the success message, not the passwords
            $result | Should -Match "$count password\(s\) generated - File Location: $testFile"
            $result | Should -Not -BeNullOrEmpty
            
            # File should exist and contain the passwords
            Test-Path $testFile | Should -Be $true
            $fileContent = Get-Content $testFile
            $fileContent.Count | Should -Be $count
        }

        It 'Should set GeneratedPasswords variable in caller scope when file write fails' {
            $invalidPath = "/root/restricted/passwords.txt"
            $count = 2
            
            # Capture both output and error streams
            $result = New-Password -Simple -NumberOfPasswords $count -OutputPath $invalidPath -NoProgress 2>&1 | Out-String
            
            # Should contain error message
            $result | Should -Match "An error occurred while writing the password file"
            
            # Should contain instructions about the variable
            $result | Should -Match "GeneratedPasswords"
            $result | Should -Match "Set-Clipboard"
        }

        It 'Should return passwords when no OutputPath is specified' {
            $count = 2
            $result = New-Password -Simple -NumberOfPasswords $count -NoProgress
            
            # Should return password strings, not a message
            $result.Count | Should -Be $count
            $result[0] | Should -Not -Match "password\(s\) generated - File Location"
        }
    }
}


