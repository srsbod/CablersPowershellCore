Describe 'New-Credential' {
    Context 'When creating a new credential' {
        It 'Should return a PSCredential object' {
            $username = 'TestUser'
            $password = 'TestPassword'
            $result = New-Credential -Username $username -Password $password
            $result | Should -BeOfType [PSCredential]
            $result.UserName | Should -Be $username
        }
    }
}
