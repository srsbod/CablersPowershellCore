Describe 'Compress-7z' {
    BeforeAll {
        # Create a temporary directory for testing
        $TempDir = Join-Path -Path $env:TEMP -ChildPath "Compress7zTest"
        if (-not (Test-Path -Path $TempDir)) {
            New-Item -Path $TempDir -ItemType Directory | Out-Null
        }

        # Create a test file and folder
        $TestFile = Join-Path -Path $TempDir -ChildPath "TestFile.txt"
        $TestFolder = Join-Path -Path $TempDir -ChildPath "TestFolder"

        Set-Content -Path $TestFile -Value "This is a test file."
        if (-not (Test-Path -Path $TestFolder)) {
            New-Item -Path $TestFolder -ItemType Directory | Out-Null
        }
        Set-Content -Path (Join-Path -Path $TestFolder -ChildPath "NestedFile.txt") -Value "This is a nested file."
    }

    AfterEach {
        # Remove any .7z files created during the tests
        Get-ChildItem -Path $TempDir -Filter "*.7z" | ForEach-Object {
            Remove-Item -Path $_.FullName -Force
        }
    }

    AfterAll {
        # Clean up temporary files and folders
        Remove-Item -Path $TempDir -Recurse -Force
    }

    Context 'When compressing a single file' {
        It 'Should create a .7z archive in the same directory if ArchivePath is not specified' {
            Compress-7z -SourcePath $TestFile
            $ExpectedArchiveFile = Join-Path -Path $TempDir -ChildPath "TestFile.txt.7z"
            Test-Path -Path $ExpectedArchiveFile | Should -Be $true
        }

        It 'Should create a .7z archive at the specified ArchivePath' {
            $CustomArchivePath = Join-Path -Path $TempDir -ChildPath "CustomFileArchive.7z"
            Compress-7z -SourcePath $TestFile -ArchivePath $CustomArchivePath
            Test-Path -Path $CustomArchivePath | Should -Be $true
        }
    }

    Context 'When compressing a folder' {
        It 'Should create a .7z archive in the same directory if ArchivePath is not specified' {
            Compress-7z -SourcePath $TestFolder
            $ExpectedArchiveFolder = Join-Path -Path $TempDir -ChildPath "TestFolder.7z"
            Test-Path -Path $ExpectedArchiveFolder | Should -Be $true
        }

        It 'Should create a .7z archive at the specified ArchivePath' {
            $CustomArchivePath = Join-Path -Path $TempDir -ChildPath "CustomFolderArchive.7z"
            Compress-7z -SourcePath $TestFolder -ArchivePath $CustomArchivePath
            Test-Path -Path $CustomArchivePath | Should -Be $true
        }
    }

    Context 'When the source path does not exist' {
        It 'Should throw an error' {
            { Compress-7z -SourcePath "$TempDir\NonExistent.txt" } | Should -Throw
        }
    }

    Context 'When using the -DeleteOriginal parameter' {
        It 'Should delete the original file after compression' {
            Compress-7z -SourcePath $TestFile -DeleteOriginal
            Test-Path -Path $TestFile | Should -Be $false
            $ExpectedArchiveFile = Join-Path -Path $TempDir -ChildPath "TestFile.txt.7z"
            Test-Path -Path $ExpectedArchiveFile | Should -Be $true
        }

        It 'Should delete the original folder after compression' {
            Compress-7z -SourcePath $TestFolder -DeleteOriginal
            Test-Path -Path $TestFolder | Should -Be $false
            $ExpectedArchiveFolder = Join-Path -Path $TempDir -ChildPath "TestFolder.7z"
            Test-Path -Path $ExpectedArchiveFolder | Should -Be $true
        }
    }
}


