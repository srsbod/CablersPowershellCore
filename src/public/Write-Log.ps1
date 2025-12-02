<#
.SYNOPSIS
    Writes log messages with timestamps to console and optionally to a file.

.DESCRIPTION
    A logging function that can be used globally across all scripts. It supports
    different log levels (DEBUG, INFO, WARNING, ERROR) and allows logging to console
    and optionally to a log file. By default, messages are written to console only.
    To enable file logging, specify the LogPath parameter. The function supports
    configurable options for log file location and log rotation.

.PARAMETER Message
    The message to log. This parameter is mandatory but can be empty or blank.
    Empty messages will result in a log entry with just the timestamp and level.

.PARAMETER Level
    The log level for the message. Valid values are DEBUG, INFO, WARNING, and ERROR.
    Default is INFO.

.PARAMETER LogPath
    The path to the log file. If specified, messages will be written to both console
    and the log file. If not specified, messages are written to console only.
    If the directory does not exist, it will be created automatically.

.PARAMETER NoConsole
    Switch to disable console logging. Useful when you only want to log to a file.

.PARAMETER MaxFileSizeMB
    Maximum log file size in megabytes before rotation. Default is 10MB.
    When the file exceeds this size, it will be rotated. Only applies when LogPath is specified.

.PARAMETER MaxLogFiles
    Maximum number of rotated log files to keep. Default is 5.
    Older files beyond this count will be deleted. Only applies when LogPath is specified.

.PARAMETER MinLogLevel
    The minimum log level to output. Messages with a level below this will not be logged.
    Valid values are DEBUG, INFO, WARNING, and ERROR. Default is INFO.

.EXAMPLE
    Write-Log -Message "Application started"

    Logs an INFO level message to the console only.

.EXAMPLE
    Write-Log -Message "An error occurred" -Level ERROR

    Logs an ERROR level message to the console only.

.EXAMPLE
    Write-Log -Message "Debug information" -Level DEBUG -MinLogLevel DEBUG

    Logs a DEBUG level message to the console when DEBUG level logging is enabled.

.EXAMPLE
    Write-Log -Message "Log to file" -LogPath "C:\Logs\myapp.log"

    Logs a message to both console and the specified log file. The directory will be created if it doesn't exist.

.EXAMPLE
    Write-Log -Message "File only message" -LogPath "C:\Logs\myapp.log" -NoConsole

    Logs a message only to the log file, not to the console.

.EXAMPLE
    Write-Log -Message "With rotation" -LogPath "C:\Logs\myapp.log" -MaxFileSizeMB 5 -MaxLogFiles 3

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
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Message = '',

        [Parameter(Mandatory = $false)]
        [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$LogPath,

        [Parameter(Mandatory = $false)]
        [switch]$NoConsole,

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

        # Format the log message - trim trailing space if message is empty
        if ([string]::IsNullOrEmpty($Message)) {
            $FormattedMessage = "$Timestamp [$Level]"
        } else {
            $FormattedMessage = "$Timestamp [$Level] $Message"
        }

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

        # File logging (only if LogPath is specified)
        if (-not [string]::IsNullOrEmpty($LogPath)) {
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


