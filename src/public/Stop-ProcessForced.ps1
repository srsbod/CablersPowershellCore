function Stop-ProcessForced {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "ProcessName"
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "ProcessID"
        )]
        [ValidateNotNullOrEmpty()]
        [int]$ID
    )

    begin {
        # Validate the process exists
        if ($ID -and -not (Get-Process -Id $ID -ErrorAction SilentlyContinue)) {
            throw "Process with ID $ID does not exist"
        }
        elseif ($Name -and -not (Get-Process -Name $Name -ErrorAction SilentlyContinue)) {
            throw "Process with name $Name does not exist"
        }
    }

    process {

        if ($ID) {
            if ($PSCmdlet.ShouldProcess($ID, "Stop process with ID")) {
                Try {
                    TaskKill /PID $ID /F
                }
                Catch {
                    Throw "Failed to stop process with ID $($_.Id). Error: $_"
                }
            }
        }
        if ($Name) {
            If ($PSCmdlet.ShouldProcess($Name, "Stop process with name")) {
                Get-Process -Name $Name | ForEach-Object {
                    Try {
                        TaskKill /PID $_.Id /F
                    }
                    Catch {
                        Throw "Failed to stop process with ID $($_.Id). Error: $_"
                    }
                }
            }
        }
    }

    end {

    }
}
