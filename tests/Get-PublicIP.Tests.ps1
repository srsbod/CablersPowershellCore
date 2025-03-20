Describe 'Get-PublicIP' {
    Context 'When retrieving the public IP address' {
        It 'Should return a valid IP address' {
            $result = Get-PublicIP
            $result | Should -Match '^\d{1,3}(\.\d{1,3}){3}$'
        }

        It 'Should copy the IP address to the clipboard when -CopyToClipboard is specified' {
            Get-PublicIP -CopyToClipboard | Out-Null
            (Get-Clipboard) | Should -Match '^\d{1,3}(\.\d{1,3}){3}$'
        }
    }
}
