function Convert-PrefixToSubnetMask {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateRange(1, 32)]
        [int]$prefixLength
    )
    $binaryMask = ('1' * $prefixLength).PadRight(32, '0')
    $subnetMask = [string]::Join('.', ($binaryMask -split '(.{8})' | Where-Object { $_ -ne '' } | ForEach-Object { [convert]::ToInt32($_, 2) }))
    return $subnetMask
}
