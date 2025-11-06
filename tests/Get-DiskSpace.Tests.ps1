Describe 'Get-DiskSpace' {
    Context 'When running on a supported platform' {
        BeforeAll {
            $originalPlatform = $PSVersionTable.Platform
            $PSVersionTable.Platform = 'Win32NT'
        }

        AfterAll {
            $PSVersionTable.Platform = $originalPlatform
        }

        It 'Should return disk space information for all drives when no parameters are specified' {
            $result = Get-DiskSpace
            $result | Should -Not -BeNullOrEmpty
            foreach ($drive in $result) {
                $drive.Drive | Should -Match "^[A-Z]:\\$" -Because "Drive should be in the format 'C:\'"
            }
        }

        It 'Should return disk space information for specified drive letters' {
            $result = Get-DiskSpace -DriveLetter @('C', 'D')
            $result | Should -Not -BeNullOrEmpty
            foreach ($drive in $result) {
                $drive.Drive | Should -BeIn @('C:\', 'D:\') -Because "Drive should match the specified drive letters"
            }
        }

        It 'Should throw an error for invalid drive letters' {
            { Get-DiskSpace -DriveLetter 'InvalidDrive' } | Should -Throw
        }

        It 'Should return a simple string output when -Simple is specified' {
            $result = Get-DiskSpace -Simple
            $result | Should -Not -BeNullOrEmpty
            foreach ($output in $result) {
                $output | Should -BeOfType [string] -Because "Output should be a string when -Simple is specified"
            }
        }
    }

    Context 'When running on an unsupported platform' {
        BeforeAll {
            $originalPlatform = $PSVersionTable.Platform
            $PSVersionTable.Platform = 'Linux'
        }

        AfterAll {
            $PSVersionTable.Platform = $originalPlatform
        }

        It 'Should throw an error' {
            { Get-DiskSpace } | Should -Throw
        }
    }
}


