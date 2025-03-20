<#
.SYNOPSIS
    Sets the audio volume or mutes/unmutes the audio.

.DESCRIPTION
    This function allows you to set the audio volume to a specific level or mute/unmute the audio.

.PARAMETER Volume
    The volume level to set, ranging from 0 to 100.

.PARAMETER Mute
    A switch to mute the audio.

.EXAMPLE
    Set-AudioVolume -Volume 50
    Sets the audio volume to 50%.

.EXAMPLE
    Set-AudioVolume -Mute
    Mutes the audio.

#>
function Set-AudioVolume {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Volume", Position = 0)]
        [ValidateRange(0, 100)]
        [int]$Volume,
        [Parameter(Mandatory = $true, ParameterSetName = "Mute")]
        [switch]$Mute
    )

    begin {

    }

    process {
        If ($PSCmdlet.ShouldProcess("Set volume to $Volume")) {
            if ($Mute) {
                Set-AudioMute $True
            }
            else {
                [Audio]::Volume = $Volume / 100
                Set-AudioMute $False
            }
        }
    }

    end {

    }
}
