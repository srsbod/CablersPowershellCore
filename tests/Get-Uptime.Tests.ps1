Describe 'Get-Uptime' {
    Context 'When retrieving uptime' {
        It 'Should return a valid timespan object' {
            Mock -CommandName Get-LastBootTime -MockWith { (Get-Date).AddDays(-5).ToString() }
            $result = Get-Uptime
            $result | Should -BeOfType [timespan]
        }

        It 'Should calculate uptime correctly' {
            Mock -CommandName Get-LastBootTime -MockWith { (Get-Date).AddDays(-5).ToString() }
            $result = Get-Uptime
            $result.Days | Should -Be 5
        }
    }

    Context 'When handling errors' {
        It 'Should throw an error if Get-LastBootTime fails' {
            Mock -CommandName Get-LastBootTime -MockWith { throw "Failed to retrieve last boot time" }
            { Get-Uptime } | Should -Throw -ExpectedMessage "Failed to retrieve last boot time"
        }
    }
}


