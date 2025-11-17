Describe 'Test-EmptyFolder' {
    Context 'When testing if a folder is empty' {
        BeforeAll {
            # Use /tmp for Linux/Unix or fallback to TestDrive
            $TempDir = Join-Path -Path "/tmp" -ChildPath "TestEmptyFolder"
            if (-not (Test-Path -Path $TempDir)) {
                New-Item -Path $TempDir -ItemType Directory | Out-Null
            }
            $TempDir2 = Join-Path -Path "/tmp" -ChildPath "TestEmptyFolder2"
            if (-not (Test-Path -Path $TempDir2)) {
                New-Item -Path $TempDir2 -ItemType Directory | Out-Null
            }
            $NonEmptyDir = Join-Path -Path "/tmp" -ChildPath "TestNonEmptyFolder"
            if (-not (Test-Path -Path $NonEmptyDir)) {
                New-Item -Path $NonEmptyDir -ItemType Directory | Out-Null
            }
            New-Item -Path (Join-Path -Path $NonEmptyDir -ChildPath "TestFile.txt") -ItemType File -Force | Out-Null
        }

        AfterAll {
            Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path $TempDir2 -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path $NonEmptyDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It 'Should return true for an empty folder with explicit path' {
            Test-EmptyFolder -Path $TempDir | Should -Be $true
        }

        It 'Should return false for a folder with files' {
            Test-EmptyFolder -Path $NonEmptyDir | Should -Be $false
        }

        It 'Should work with current directory when no path specified' {
            Push-Location $TempDir
            try {
                Test-EmptyFolder | Should -Be $true
            }
            finally {
                Pop-Location
            }
        }

        It 'Should accept pipeline input for single path' {
            $TempDir | Test-EmptyFolder | Should -Be $true
        }

        It 'Should accept pipeline input for multiple paths' {
            $results = @($TempDir, $TempDir2) | Test-EmptyFolder
            $results.Count | Should -Be 2
            $results[0] | Should -Be $true
            $results[1] | Should -Be $true
        }

        It 'Should work with Get-ChildItem pipeline input' {
            Push-Location "/tmp"
            try {
                $result = Get-ChildItem -Path "/tmp" -Filter "TestEmptyFolder" -Directory | Test-EmptyFolder
                $result | Should -Be $true
            }
            finally {
                Pop-Location
            }
        }

        It 'Should work with alias isempty' {
            $TempDir | isempty | Should -Be $true
        }
    }
}


