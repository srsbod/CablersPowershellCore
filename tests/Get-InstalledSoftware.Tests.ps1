Describe 'Get-InstalledSoftware' {
    Context 'When retrieving installed software' {
        It 'Should return all installed software if no name is specified' {
            Mock -CommandName Get-ChildItem -MockWith { 
                @([PSCustomObject]@{ 
                        DisplayName          = "TestSoftware"; 
                        DisplayVersion       = "1.0.0"; 
                        PSChildName          = "{1234-5678}"; 
                        Publisher            = "TestPublisher"; 
                        InstallDate          = "20230101"; 
                        UninstallString      = "uninstall.exe"; 
                        QuietUninstallString = "quietuninstall.exe" 
                    }) 
            }
            Mock -CommandName Get-ItemProperty -MockWith { 
                param ($Path)
                @([PSCustomObject]@{ 
                        DisplayName          = "TestSoftware"; 
                        DisplayVersion       = "1.0.0"; 
                        PSChildName          = "{1234-5678}"; 
                        Publisher            = "TestPublisher"; 
                        InstallDate          = "20230101"; 
                        UninstallString      = "uninstall.exe"; 
                        QuietUninstallString = "quietuninstall.exe" 
                    }) 
            }
            $result = Get-InstalledSoftware
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return software matching the specified name' {
            Mock -CommandName Get-ChildItem -MockWith { 
                @([PSCustomObject]@{ 
                        DisplayName          = "TestSoftware"; 
                        DisplayVersion       = "1.0.0"; 
                        PSChildName          = "{1234-5678}"; 
                        Publisher            = "TestPublisher"; 
                        InstallDate          = "20230101"; 
                        UninstallString      = "uninstall.exe"; 
                        QuietUninstallString = "quietuninstall.exe" 
                    }) 
            }
            Mock -CommandName Get-ItemProperty -MockWith { 
                param ($Path)
                @([PSCustomObject]@{ 
                        DisplayName          = "TestSoftware"; 
                        DisplayVersion       = "1.0.0"; 
                        PSChildName          = "{1234-5678}"; 
                        Publisher            = "TestPublisher"; 
                        InstallDate          = "20230101"; 
                        UninstallString      = "uninstall.exe"; 
                        QuietUninstallString = "quietuninstall.exe" 
                    }) 
            }
            $result = Get-InstalledSoftware -SoftwareName "TestSoftware"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "TestSoftware"
        }

        It 'Should throw an error if registry access fails' {
            Mock -CommandName Get-ChildItem -MockWith { throw "Registry access error" }
            { Get-InstalledSoftware } | Should -Throw
        }
    }
}
