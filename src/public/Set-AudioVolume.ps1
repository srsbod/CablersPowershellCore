function Set-AudioVolume {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Volume", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [int]$Volume,
        [Parameter(Mandatory = $true, ParameterSetName = "Mute", Position = 0)]
        [switch]$Mute
    )

    begin {
        # Validate the volume is between 0 and 100
        if ($Volume -lt 0 -or $Volume -gt 100) {
            throw "Volume must be between 0 and 100"
        }
    }

    process {
        If ($PSCmdlet.ShouldProcess("Set volume to $Volume")) {
            if ($Mute) {
                [Audio]::Mute = $true
            }
            else {
                [Audio]::Volume = $Volume / 100
                [Audio]::Mute = $false
            }
        }
    }

    end {

    }
}
