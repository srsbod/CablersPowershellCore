Describe 'Write-Log' {
    BeforeAll {
        $TempLogDir = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'WriteLogTests'
        if (-not (Test-Path -Path $TempLogDir)) {
            New-Item -Path $TempLogDir -ItemType Directory | Out-Null
        }
        $TestLogPath = Join-Path -Path $TempLogDir -ChildPath 'test.log'
    }

    AfterAll {
        Remove-Item -Path $TempLogDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    BeforeEach {
        # Clean up log files before each test
        Remove-Item -Path "$TempLogDir/*.log*" -Force -ErrorAction SilentlyContinue
    }

    Context 'Basic logging functionality' {
        It 'Should write a message to the log file' {
            Write-Log -Message 'Test message' -LogPath $TestLogPath -NoConsole
            Test-Path -Path $TestLogPath | Should -Be $true
        }

        It 'Should include timestamp in correct format YYYY-MM-DD HH:MM:SS' {
            Write-Log -Message 'Timestamp test' -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'
        }

        It 'Should include the log level in the message' {
            Write-Log -Message 'Level test' -Level INFO -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match '\[INFO\]'
        }

        It 'Should include the actual message' {
            $testMessage = 'This is a unique test message'
            Write-Log -Message $testMessage -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match $testMessage
        }
    }

    Context 'Log levels' {
        It 'Should support DEBUG level' {
            Write-Log -Message 'Debug' -Level DEBUG -MinLogLevel DEBUG -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match '\[DEBUG\]'
        }

        It 'Should support INFO level' {
            Write-Log -Message 'Info' -Level INFO -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match '\[INFO\]'
        }

        It 'Should support WARNING level' {
            Write-Log -Message 'Warning' -Level WARNING -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match '\[WARNING\]'
        }

        It 'Should support ERROR level' {
            Write-Log -Message 'Error' -Level ERROR -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match '\[ERROR\]'
        }

        It 'Should default to INFO level when no level specified' {
            Write-Log -Message 'Default level' -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match '\[INFO\]'
        }
    }

    Context 'MinLogLevel filtering' {
        It 'Should filter out DEBUG messages when MinLogLevel is INFO (default)' {
            Write-Log -Message 'Debug message' -Level DEBUG -LogPath $TestLogPath -NoConsole
            Test-Path -Path $TestLogPath | Should -Be $false
        }

        It 'Should show INFO messages when MinLogLevel is INFO' {
            Write-Log -Message 'Info message' -Level INFO -MinLogLevel INFO -LogPath $TestLogPath -NoConsole
            Test-Path -Path $TestLogPath | Should -Be $true
        }

        It 'Should filter out INFO and DEBUG when MinLogLevel is WARNING' {
            Write-Log -Message 'Debug' -Level DEBUG -MinLogLevel WARNING -LogPath $TestLogPath -NoConsole
            Write-Log -Message 'Info' -Level INFO -MinLogLevel WARNING -LogPath $TestLogPath -NoConsole
            Test-Path -Path $TestLogPath | Should -Be $false
        }

        It 'Should show WARNING and ERROR when MinLogLevel is WARNING' {
            Write-Log -Message 'Warning' -Level WARNING -MinLogLevel WARNING -LogPath $TestLogPath -NoConsole
            Write-Log -Message 'Error' -Level ERROR -MinLogLevel WARNING -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match '\[WARNING\]'
            $content | Should -Match '\[ERROR\]'
        }

        It 'Should only show ERROR when MinLogLevel is ERROR' {
            Write-Log -Message 'Debug' -Level DEBUG -MinLogLevel ERROR -LogPath $TestLogPath -NoConsole
            Write-Log -Message 'Info' -Level INFO -MinLogLevel ERROR -LogPath $TestLogPath -NoConsole
            Write-Log -Message 'Warning' -Level WARNING -MinLogLevel ERROR -LogPath $TestLogPath -NoConsole
            Write-Log -Message 'Error' -Level ERROR -MinLogLevel ERROR -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match '\[ERROR\]'
            $content | Should -Not -Match '\[DEBUG\]'
            $content | Should -Not -Match '\[INFO\]'
            $content | Should -Not -Match '\[WARNING\]'
        }

        It 'Should show all levels when MinLogLevel is DEBUG' {
            Write-Log -Message 'Debug' -Level DEBUG -MinLogLevel DEBUG -LogPath $TestLogPath -NoConsole
            Write-Log -Message 'Info' -Level INFO -MinLogLevel DEBUG -LogPath $TestLogPath -NoConsole
            Write-Log -Message 'Warning' -Level WARNING -MinLogLevel DEBUG -LogPath $TestLogPath -NoConsole
            Write-Log -Message 'Error' -Level ERROR -MinLogLevel DEBUG -LogPath $TestLogPath -NoConsole
            $lines = Get-Content -Path $TestLogPath
            $lines.Count | Should -Be 4
        }
    }

    Context 'Console and file logging options' {
        It 'Should not write to file when LogPath is not specified' {
            # This test verifies default behavior (console only)
            # Since we cannot easily capture console output, we verify no file is created
            $defaultLogPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'CablersPowershellCore.log'
            Remove-Item -Path $defaultLogPath -Force -ErrorAction SilentlyContinue
            Write-Log -Message 'Console only by default'
            Test-Path -Path $defaultLogPath | Should -Be $false
        }

        It 'Should write to file when LogPath is specified' {
            Write-Log -Message 'File and console' -LogPath $TestLogPath
            Test-Path -Path $TestLogPath | Should -Be $true
        }

        It 'Should write to file only when LogPath is specified with NoConsole' {
            Write-Log -Message 'File only' -LogPath $TestLogPath -NoConsole
            Test-Path -Path $TestLogPath | Should -Be $true
        }
    }

    Context 'Log file path handling' {
        It 'Should create log directory if it does not exist' {
            $newDir = Join-Path -Path $TempLogDir -ChildPath 'newsubdir/deep/path'
            $newLogPath = Join-Path -Path $newDir -ChildPath 'test.log'
            
            Write-Log -Message 'New directory test' -LogPath $newLogPath -NoConsole
            
            Test-Path -Path $newLogPath | Should -Be $true
        }

        It 'Should use custom log path when specified' {
            $customPath = Join-Path -Path $TempLogDir -ChildPath 'custom.log'
            Write-Log -Message 'Custom path' -LogPath $customPath -NoConsole
            Test-Path -Path $customPath | Should -Be $true
        }
    }

    Context 'Log rotation' {
        It 'Should rotate log when file exceeds MaxFileSizeMB' {
            $rotationLogPath = Join-Path -Path $TempLogDir -ChildPath 'rotation.log'
            
            # Create a file larger than 1MB
            $largeContent = 'A' * 1048576  # 1MB
            Set-Content -Path $rotationLogPath -Value $largeContent
            
            # This should trigger rotation
            Write-Log -Message 'Rotation trigger' -LogPath $rotationLogPath -MaxFileSizeMB 1 -NoConsole
            
            # Check if rotation happened
            Test-Path -Path "$rotationLogPath.1" | Should -Be $true
            
            # New log should contain only the new message
            $newContent = Get-Content -Path $rotationLogPath -Raw
            $newContent | Should -Match 'Rotation trigger'
        }

        It 'Should keep only MaxLogFiles rotated files' {
            $rotationLogPath = Join-Path -Path $TempLogDir -ChildPath 'maxfiles.log'
            
            # Create initial rotated files
            for ($i = 1; $i -le 5; $i++) {
                Set-Content -Path "$rotationLogPath.$i" -Value "Old log $i"
            }
            
            # Create a large current log to trigger rotation
            $largeContent = 'A' * 1048576
            Set-Content -Path $rotationLogPath -Value $largeContent
            
            # Trigger rotation with MaxLogFiles = 3
            Write-Log -Message 'Max files test' -LogPath $rotationLogPath -MaxFileSizeMB 1 -MaxLogFiles 3 -NoConsole
            
            # Files beyond MaxLogFiles should be deleted
            Test-Path -Path "$rotationLogPath.4" | Should -Be $false
            Test-Path -Path "$rotationLogPath.5" | Should -Be $false
        }
    }

    Context 'Pipeline input' {
        It 'Should accept message from pipeline' {
            'Pipeline message' | Write-Log -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match 'Pipeline message'
        }
    }

    Context 'Parameter validation' {
        It 'Should reject invalid Level values' {
            { Write-Log -Message 'Test' -Level 'INVALID' -LogPath $TestLogPath -NoConsole } | Should -Throw
        }

        It 'Should reject invalid MinLogLevel values' {
            { Write-Log -Message 'Test' -MinLogLevel 'INVALID' -LogPath $TestLogPath -NoConsole } | Should -Throw
        }

        It 'Should reject MaxFileSizeMB less than 1' {
            { Write-Log -Message 'Test' -MaxFileSizeMB 0 -LogPath $TestLogPath -NoConsole } | Should -Throw
        }

        It 'Should reject MaxLogFiles less than 1' {
            { Write-Log -Message 'Test' -MaxLogFiles 0 -LogPath $TestLogPath -NoConsole } | Should -Throw
        }
    }

    Context 'Empty and blank message handling' {
        It 'Should accept empty string message' {
            { Write-Log -Message '' -LogPath $TestLogPath -NoConsole } | Should -Not -Throw
            Test-Path -Path $TestLogPath | Should -Be $true
        }

        It 'Should log timestamp and level for empty message' {
            Write-Log -Message '' -LogPath $TestLogPath -NoConsole
            $content = Get-Content -Path $TestLogPath -Raw
            $content | Should -Match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[INFO\]'
        }

        It 'Should accept null message from pipeline' {
            { $null | Write-Log -LogPath $TestLogPath -NoConsole } | Should -Not -Throw
        }

        It 'Should handle mixed content with blank lines from pipeline' {
            @('Line 1', '', 'Line 3') | Write-Log -LogPath $TestLogPath -NoConsole
            $lines = Get-Content -Path $TestLogPath
            $lines.Count | Should -Be 3
            $lines[0] | Should -Match 'Line 1'
            $lines[1] | Should -Match '\[INFO\]$'
            $lines[2] | Should -Match 'Line 3'
        }
    }
}


