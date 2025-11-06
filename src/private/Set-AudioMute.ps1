function Set-AudioMute {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [bool]$Mute
    )
    
    [Audio]::Mute = $Mute
}


