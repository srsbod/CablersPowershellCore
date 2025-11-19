# Import private functions
foreach ($file in Get-ChildItem -Path "$PSScriptRoot\src\private" -Filter *.ps1) {
    . $file.FullName
}

# Import public functions
foreach ($file in Get-ChildItem -Path "$PSScriptRoot\src\public" -Filter *.ps1) {
    . $file.FullName
}

Set-Alias -Name Get-InstalledApps -Value Get-InstalledSoftware
Set-Alias -Name Uninstall-Apps -Value Uninstall-Software
Set-Alias -Name ip -Value Get-InternalIP
Set-Alias -Name ipLocation -Value Get-IPAddressLocation
Set-Alias -Name uptime -Value Get-Uptime
Set-Alias -Name lastBoot -Value Get-LastBootTime
Set-Alias -Name publicIP -Value Get-PublicIP
Set-Alias -Name isEmpty -Value Test-EmptyFolder
Set-Alias -Name isAdmin -Value Test-IsAdmin


