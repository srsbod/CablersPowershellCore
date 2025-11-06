# Function to split a string based on a specified substring, either before or after it.

#TODO change this to take the split string as a single parameter and a switch to indicate before or after, with after as the default

function Split-String {

    [CmdletBinding(DefaultParameterSetName = 'After')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$InputString,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Before')]
        [string]$SplitBefore, #Returns everything up to the split string

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'After')]
        [string]$SplitAfter, #Returns everything up to and including the split string

        [Parameter (Mandatory = $false)]
        [switch]$ReturnBoth = $false #Returns both parts, still honors splitbefore and splitafter
    )
    
    begin {
        # No validation needed

        Write-Debug "InputString: $InputString"
        Write-Debug "SplitBefore: $SplitBefore"
        Write-Debug "SplitAfter: $SplitAfter"
        Write-Debug "ReturnBoth: $ReturnBoth"
        Write-Debug "ParameterSetName: $($PSCmdlet.ParameterSetName)"

    }
    
    process {
        
        try {
            
            if ($InputString -notmatch [regex]::Escape($SplitBefore)) {
                throw "The specified substring '$SplitBefore' was not found in the input string."
            }

            if ($PSCmdlet.ParameterSetName -eq 'Before') {
                $parts = $InputString -split [regex]::Escape($SplitBefore), 2
                Write-Debug "Parts: $($parts | Out-String)"
                if ($ReturnBoth) {
                    $parts[0], ($SplitBefore + $parts[1])
                } else {
                    $parts[0]
                }
            } elseif ($PSCmdlet.ParameterSetName -eq 'After') {
                $parts = $InputString -split [regex]::Escape($SplitAfter), 2
                Write-Debug "Parts: `n$($parts | Out-String)"
                if ($ReturnBoth) {
                    ($parts[0] + $SplitAfter), $parts[1]
                } else {
                    ($parts[0] + $SplitAfter)
                }
            } else {
                throw "Invalid parameter set."
            }
        } catch {
            throw $_
        }
    }

    end {
        
    }
}

