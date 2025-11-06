Describe 'Test-EmptyFolder' {
    Context 'When testing if a folder is empty' {
        BeforeAll {
            $TempDir = Join-Path -Path $env:TEMP -ChildPath "TestEmptyFolder"
            if (-not (Test-Path -Path $TempDir)) {
                New-Item -Path $TempDir -ItemType Directory | Out-Null
            }
        }

        AfterAll {
            Remove-Item -Path $TempDir -Recurse -Force
        }

        It 'Should return true for an empty folder' {
            Test-EmptyFolder -Path $TempDir | Should -Be $true
        }

        It 'Should return false for a folder with files' {
            New-Item -Path (Join-Path -Path $TempDir -ChildPath "TestFile.txt") -ItemType File | Out-Null
            Test-EmptyFolder -Path $TempDir | Should -Be $false
        }
    }
}


