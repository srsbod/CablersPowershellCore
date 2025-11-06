function Convert-StringToURI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("URL")]
        [string]$inputString
    )

    try {
        # Use EscapeDataString for encoding components (recommended for query values)
        $escapedString = [System.Uri]::EscapeDataString($inputString)
        return $escapedString
    } catch {
        # Re-throw with context
        throw "Failed to escape string for URI: $($_.Exception.Message)"
    }
}
