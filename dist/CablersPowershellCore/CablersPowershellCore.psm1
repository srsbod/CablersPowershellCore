# Import private functions
Get-ChildItem -Path "$PSScriptRoot\..\..\src\private" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Import public functions
Get-ChildItem -Path "$PSScriptRoot\..\..\src\public" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}
