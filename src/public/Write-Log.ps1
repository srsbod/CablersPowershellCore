<#
.SYNOPSIS
    Writes log messages with timestamps to console and/or file.

.DESCRIPTION
    A logging function that can be used globally across all scripts. It supports
    different log levels (DEBUG, INFO, WARNING, ERROR) and allows logging to both
    console and a log file. The function supports configurable options for log
    file location and log rotation.

.PARAMETER Message
    The message to log. This parameter is mandatory.

.PARAMETER Level
    The log level for the message. Valid values are DEBUG, INFO, WARNING, and ERROR.
    Default is INFO.

.PARAMETER LogPath
    The path to the log file. Default is the system temp directory with filename 'CablersPowershellCore.log'.
    If the directory does not exist, it will be created automatically.

.PARAMETER NoConsole
    Switch to disable console logging. Default is to log to console.

.PARAMETER NoFile
    Switch to disable file logging. Default is to log to file.

.PARAMETER MaxFileSizeMB
    Maximum log file size in megabytes before rotation. Default is 10MB.
    When the file exceeds this size, it will be rotated.

.PARAMETER MaxLogFiles
    Maximum number of rotated log files to keep. Default is 5.
    Older files beyond this count will be deleted.

.PARAMETER MinLogLevel
    The minimum log level to output. Messages with a level below this will not be logged.
    Valid values are DEBUG, INFO, WARNING, and ERROR. Default is INFO.

.EXAMPLE
    Write-Log -Message "Application started"

    Logs an INFO level message to both console and the default log file.

.EXAMPLE
    Write-Log -Message "An error occurred" -Level ERROR

    Logs an ERROR level message to both console and the default log file.

.EXAMPLE
    Write-Log -Message "Debug information" -Level DEBUG -MinLogLevel DEBUG

    Logs a DEBUG level message when DEBUG level logging is enabled.

.EXAMPLE
    Write-Log -Message "File only message" -NoConsole

    Logs a message only to the log file, not to the console.

.EXAMPLE
    Write-Log -Message "Console only message" -NoFile

    Logs a message only to the console, not to a file.

.EXAMPLE
    Write-Log -Message "Custom path" -LogPath "C:\Logs\myapp.log"

    Logs a message to a custom log file location. The directory will be created if it doesn't exist.

.EXAMPLE
    Write-Log -Message "With rotation" -MaxFileSizeMB 5 -MaxLogFiles 3

    Logs with custom rotation settings: rotate when file exceeds 5MB, keep only 3 archived logs.

.OUTPUTS
    None. This function writes to console and/or file but does not output to the pipeline.

.NOTES
    Log file format: YYYY-MM-DD HH:MM:SS [LEVEL] Message
    Rotated files are named with .1, .2, etc. suffixes (e.g., app.log.1, app.log.2)

#>
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$LogPath = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'CablersPowershellCore.log'),

        [Parameter(Mandatory = $false)]
        [switch]$NoConsole,

        [Parameter(Mandatory = $false)]
        [switch]$NoFile,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 1000)]
        [int]$MaxFileSizeMB = 10,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 100)]
        [int]$MaxLogFiles = 5,

        [Parameter(Mandatory = $false)]
        [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR')]
        [string]$MinLogLevel = 'INFO'
    )

    begin {
        # Define log level hierarchy for comparison
        $LogLevelPriority = @{
            'DEBUG'   = 0
            'INFO'    = 1
            'WARNING' = 2
            'ERROR'   = 3
        }
    }

    process {
        # Check if message level meets minimum threshold
        if ($LogLevelPriority[$Level] -lt $LogLevelPriority[$MinLogLevel]) {
            return
        }

        # Format timestamp as YYYY-MM-DD HH:MM:SS
        $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

        # Format the log message
        $FormattedMessage = "$Timestamp [$Level] $Message"

        # Console logging
        if (-not $NoConsole) {
            switch ($Level) {
                'DEBUG' {
                    Write-Host $FormattedMessage -ForegroundColor Gray
                }
                'INFO' {
                    Write-Host $FormattedMessage -ForegroundColor White
                }
                'WARNING' {
                    Write-Host $FormattedMessage -ForegroundColor Yellow
                }
                'ERROR' {
                    Write-Host $FormattedMessage -ForegroundColor Red
                }
            }
        }

        # File logging
        if (-not $NoFile) {
            # Ensure log directory exists
            $LogDirectory = Split-Path -Path $LogPath -Parent
            if (-not [string]::IsNullOrEmpty($LogDirectory) -and -not (Test-Path -Path $LogDirectory)) {
                New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
            }

            # Check if log rotation is needed
            if (Test-Path -Path $LogPath) {
                $LogFile = Get-Item -Path $LogPath
                $FileSizeInMB = $LogFile.Length / 1MB

                if ($FileSizeInMB -ge $MaxFileSizeMB) {
                    # Perform log rotation
                    # Delete any log files at or beyond MaxLogFiles
                    $i = $MaxLogFiles
                    while ($true) {
                        $OldLogPath = "$LogPath.$i"
                        if (Test-Path -Path $OldLogPath) {
                            Remove-Item -Path $OldLogPath -Force
                            $i++
                        } else {
                            break
                        }
                    }

                    # Shift existing rotated logs
                    for ($i = $MaxLogFiles - 1; $i -ge 1; $i--) {
                        $CurrentPath = "$LogPath.$i"
                        $NewPath = "$LogPath.$($i + 1)"
                        if (Test-Path -Path $CurrentPath) {
                            Move-Item -Path $CurrentPath -Destination $NewPath -Force
                        }
                    }

                    # Rename current log to .1
                    Move-Item -Path $LogPath -Destination "$LogPath.1" -Force
                }
            }

            # Append message to log file
            Add-Content -Path $LogPath -Value $FormattedMessage -Encoding UTF8
        }
    }

    end {
    }
}


