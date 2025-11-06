<#
.SYNOPSIS
    Finds the longest common prefix string amongst an array of strings.

.DESCRIPTION
    This function takes an array of strings and determines the longest common prefix shared among them.
    Useful for finding the common prefix of file paths or similar strings.

.PARAMETER Strings
    An array of strings for which the longest common prefix is to be found.
    If a single string is passed, the whole string will be returned.

.EXAMPLE
    $result = Get-LongestCommonPrefix -Strings @("flower", "flow", "flight")
    Write-Output $result
    # Output: "fl"

.NOTES
    The function assumes that the input array contains at least one string.
    If the array is empty, the function will throw an error.

#>

function Get-LongestCommonPrefix {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$Strings
    )
    
    if ($Strings.Length -eq 0) {
        throw "Input array must contain at least one string."
    }

    # Sort the strings and compare the first and last, this will always provide the longest common prefix
    $Strings = $Strings | Sort-Object 
    $firstString = $Strings[0]
    $lastString = $Strings[-1]
    $result = ""

    for ($i = 0; $i -lt $firstString.Length; $i++) {
        if ($firstString[$i] -eq $lastString[$i]) {
            $result += $firstString[$i]
        } else {
            break
        }
    }

    return $result
}
