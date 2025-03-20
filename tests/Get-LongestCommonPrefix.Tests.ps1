Describe 'Get-LongestCommonPrefix' {
    Context 'When input contains multiple strings with a common prefix' {
        It 'Should return the correct common prefix' {
            $result = Get-LongestCommonPrefix -Strings @("flower", "flow", "flight")
            $result | Should -Be "fl"
        }
    }

    Context 'When input contains strings with no common prefix' {
        It 'Should return an empty string' {
            $result = Get-LongestCommonPrefix -Strings @("dog", "cat", "bird")
            $result | Should -Be ""
        }
    }

    Context 'When input contains a single string' {
        It 'Should return the entire string' {
            $result = Get-LongestCommonPrefix -Strings @("single")
            $result | Should -Be "single"
        }
    }

    Context 'When input contains an empty array' {
        It 'Should throw an error' {
            { Get-LongestCommonPrefix -Strings @() } | Should -Throw
        }
    }

    Context 'When input contains strings with varying lengths' {
        It 'Should return the correct common prefix' {
            $result = Get-LongestCommonPrefix -Strings @("interview", "internet", "internal", "interval")
            $result | Should -Be "inter"
        }
    }

    Context 'When input contains identical strings' {
        It 'Should return the string itself' {
            $result = Get-LongestCommonPrefix -Strings @("repeat", "repeat", "repeat")
            $result | Should -Be "repeat"
        }
    }

    Context 'When input contains strings with special characters' {
        It 'Should handle special characters correctly' {
            $result = Get-LongestCommonPrefix -Strings @("sp@cial", "sp@ce", "sp@rkle")
            $result | Should -Be "sp@"
        }
    }
}
