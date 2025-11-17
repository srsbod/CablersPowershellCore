Describe 'New-Passphrase' {
    Context 'When generating a passphrase' {
        It 'Should return a passphrase with default parameters' {
            $result = New-Passphrase -NoProgress -ExcludeNumbers
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return a passphrase with specified word count' {
            $wordCount = 5
            $result = New-Passphrase -WordCount $wordCount -Separator "-" -NoProgress -ExcludeNumbers
            $words = $result -split '-'
            $words.Count | Should -Be $wordCount
        }

        It 'Should return lowercase passphrase when Case is Lowercase' {
            $result = New-Passphrase -Case Lowercase -NoProgress -ExcludeNumbers -Separator "-"
            $result | Should -Match '^[a-z\-]+$' -Because 'Lowercase passphrase should only contain lowercase letters and separators'
        }

        It 'Should return uppercase passphrase when Case is Uppercase' {
            $result = New-Passphrase -Case Uppercase -NoProgress -ExcludeNumbers -Separator "-"
            $result | Should -Match '^[A-Z\-]+$' -Because 'Uppercase passphrase should only contain uppercase letters and separators'
        }

        It 'Should return titlecase passphrase when Case is Titlecase' {
            $result = New-Passphrase -Case Titlecase -NoProgress -ExcludeNumbers -Separator "-"
            $words = $result -split '-'
            foreach ($word in $words) {
                $word[0] | Should -Match '[A-Z]' -Because 'First letter should be uppercase'
                if ($word.Length -gt 1) {
                    $word.Substring(1) | Should -Match '^[a-z]+$' -Because 'Rest of word should be lowercase'
                }
            }
        }

        It 'Should return random case passphrase when Case is RandomCase' {
            $result = New-Passphrase -Case RandomCase -NoProgress -ExcludeNumbers -Separator "-"
            $words = $result -split '-'
            foreach ($word in $words) {
                # Each word should be either all uppercase or all lowercase
                ($word -cmatch '^[A-Z]+$' -or $word -cmatch '^[a-z]+$') | Should -Be $true -Because 'RandomCase should make each word entirely uppercase or lowercase'
            }
        }

        It 'Should return random letter passphrase when Case is RandomLetter' {
            $result = New-Passphrase -Case RandomLetter -NoProgress -ExcludeNumbers -Separator "-"
            $result | Should -Match '[a-zA-Z\-]+' -Because 'RandomLetter passphrase should contain mixed case letters and separators'
            
            # Test multiple times to ensure randomization is working
            $results = @()
            for ($i = 0; $i -lt 10; $i++) {
                $results += New-Passphrase -Case RandomLetter -NoProgress -ExcludeNumbers -Separator "-"
            }
            
            # Check that we have some variation in casing
            $hasVariation = $false
            foreach ($passphrase in $results) {
                if ($passphrase -cmatch '[a-z]' -and $passphrase -cmatch '[A-Z]') {
                    $hasVariation = $true
                    break
                }
            }
            $hasVariation | Should -Be $true -Because 'RandomLetter should produce mixed case letters'
        }

        It 'Should append numbers when ExcludeNumbers is not specified' {
            $result = New-Passphrase -NoProgress
            $result | Should -Match '\d+$' -Because 'Passphrase should end with numbers by default'
        }

        It 'Should not append numbers when ExcludeNumbers is specified' {
            $result = New-Passphrase -NoProgress -ExcludeNumbers -Separator "-"
            $result | Should -Not -Match '\d+$' -Because 'Passphrase should not end with numbers when ExcludeNumbers is specified'
        }

        It 'Should generate the specified number of passphrases' {
            $count = 5
            $result = New-Passphrase -NumberOfPassphrases $count -NoProgress
            $result.Count | Should -Be $count
        }

        It 'Should use the specified separator' {
            $separator = "_"
            $result = New-Passphrase -Separator $separator -NoProgress -ExcludeNumbers
            $result | Should -Match '_' -Because 'Passphrase should contain the specified separator'
        }

        It 'Should not use separator when Separator is None' {
            $result = New-Passphrase -Separator "None" -NoProgress -ExcludeNumbers -Case Lowercase
            $result | Should -Not -Match '[-_\.,\+=]' -Because 'Passphrase should not contain separators when None is specified'
        }

        It 'Should generate unique passphrases when multiple are requested' {
            $count = 10
            $result = New-Passphrase -NumberOfPassphrases $count -NoProgress
            ($result | Sort-Object | Get-Unique).Count | Should -Be $count -Because 'Generated passphrases should be unique'
        }
    }
}

