Describe 'Get-LastBootTime' {
    Context 'When retrieving the last boot time' {
        It 'Should return a valid DateTime object' {
            Mock -CommandName Get-CimInstance -MockWith {
                [PSCustomObject]@{ LastBootUpTime = (Get-Date).AddDays(-1) }
            }
            $result = Get-LastBootTime
            $result | Should -BeOfType [string]
            $result | Should -Match '^\d{2} \w+ \d{4} \d{2}:\d{2}:\d{2}$' -Because "The output should be a formatted date string."
        }

        It 'Should handle errors gracefully if CIM query fails' {
            Mock -CommandName Get-CimInstance -MockWith { throw "CIM query failed" }
            { Get-LastBootTime } | Should -Throw -ExpectedMessage "CIM query failed"
        }
    }
}
