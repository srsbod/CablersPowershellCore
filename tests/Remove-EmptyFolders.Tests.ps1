Describe 'Remove-EmptyFolders' {
    Context 'When removing empty folders' {
        BeforeEach {
            $TempDir = Join-Path -Path $env:TEMP -ChildPath "RemoveEmptyFoldersTest"
            if (-not (Test-Path -Path $TempDir)) {
                New-Item -Path $TempDir -ItemType Directory | Out-Null
            }
            New-Item -Path (Join-Path -Path $TempDir -ChildPath "EmptyFolder") -ItemType Directory | Out-Null
            New-Item -Path (Join-Path -Path $TempDir -ChildPath "EmptyFolder2") -ItemType Directory | Out-Null
            New-Item -Path (Join-Path -Path $TempDir -ChildPath "EmptyFolder2\SubFolder") -ItemType Directory | Out-Null
            New-Item -Path (Join-Path -Path $TempDir -ChildPath "NonEmptyFolder") -ItemType Directory | Out-Null
            New-Item -Path (Join-Path -Path $TempDir -ChildPath "NonEmptyFolder\TestFile.txt") -ItemType File | Out-Null
            
            $TempDir = [System.IO.Path]::GetFullPath($TempDir) # Expand path to it's full form instead of C:\users\bradle~1\
        }

        AfterEach {
            Remove-Item -Path $TempDir -Recurse -Force
        }

        It 'Should remove empty folders' {
            Remove-EmptyFolders -Path $TempDir | Should -Contain (Join-Path -Path $TempDir -ChildPath "EmptyFolder")
        }

        It 'Should remove nested empty folders' {
            Remove-EmptyFolders -Path $TempDir | Should -Contain (Join-Path -Path $TempDir -ChildPath "EmptyFolder2\SubFolder")
        }

        It 'Should not remove non-empty folders' {
            Test-Path -Path (Join-Path -Path $TempDir -ChildPath "NonEmptyFolder") | Should -Be $true
        }
    }
}
