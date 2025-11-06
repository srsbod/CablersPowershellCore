Describe 'Compare-Files' {
    BeforeAll {
        # Create temporary files for testing
        $TempDir = Join-Path -Path $env:TEMP -ChildPath "CompareFilesTest"
        if (-not (Test-Path -Path $TempDir)) {
            New-Item -Path $TempDir -ItemType Directory | Out-Null
        }

        $File1 = Join-Path -Path $TempDir -ChildPath "File1.txt"
        $File2 = Join-Path -Path $TempDir -ChildPath "File2.txt"
        $File3 = Join-Path -Path $TempDir -ChildPath "File3.txt"

        Set-Content -Path $File1 -Value "This is a test file."
        Set-Content -Path $File2 -Value "This is a test file."
        Set-Content -Path $File3 -Value "This is a different file."
    }

    AfterAll {
        # Clean up temporary files
        Remove-Item -Path $TempDir -Recurse -Force
    }

    Context 'When comparing identical files' {
        It 'Should return Match = $true' {
            $result = Compare-Files -SourceFile $File1 -ComparisonFile $File2
            $result.Match | Should -Be $true
        }
    }

    Context 'When comparing different files' {
        It 'Should return Match = $false' {
            $result = Compare-Files -SourceFile $File1 -ComparisonFile $File3
            $result.Match | Should -Be $false
        }
    }

    Context 'When a file does not exist' {
        It 'Should throw an error for a missing source file' {
            { Compare-Files -SourceFile "$TempDir\NonExistent.txt" -ComparisonFile $File1 } | Should -Throw
        }

        It 'Should throw an error for a missing comparison file' {
            { Compare-Files -SourceFile $File1 -ComparisonFile "$TempDir\NonExistent.txt" } | Should -Throw
        }
    }
}


