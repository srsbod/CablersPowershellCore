# Import private functions
foreach ($file in Get-ChildItem -Path "$PSScriptRoot\src\private" -Filter *.ps1) {
    . $file.FullName
}

# Import public functions
foreach ($file in Get-ChildItem -Path "$PSScriptRoot\src\public" -Filter *.ps1) {
    . $file.FullName
}

Set-Alias -name Get-InstalledApps -Value Get-InstalledSoftware
Set-Alias -name Uninstall-Apps -Value Uninstall-Software
Set-Alias -name ip -Value Get-InternalIP
Set-Alias -name iplocation -Value Get-IPAddressLocation
Set-Alias -name uptime -Value Get-Uptime
Set-Alias -name lastboot -Value Get-LastBootTime
Set-Alias -name publicip -Value Get-PublicIP
