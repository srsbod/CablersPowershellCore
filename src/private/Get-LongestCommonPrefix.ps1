<#
.SYNOPSIS
    Finds the longest common prefix string amongst an array of strings.

.DESCRIPTION
    This function takes an array of strings and determines the longest common prefix shared among them.
    It iterates through each string and compares characters to find the common prefix.
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

    # Initialize the minimum length to the length of the first string
    $MinLength = $Strings[0].Length

    # Iterate through each string in the array starting from the second string
    for ($i = 1; $i -lt $Strings.Length; $i++) {

        # Update the minimum length to the smallest length found so far
        $MinLength = [Math]::Min($MinLength, $Strings[$i].Length)

        # Compare characters of the current string with the first string up to the minimum length
        for ($j = 0; $j -lt $MinLength; $j++) {

            # If characters do not match, update the minimum length to the current position and finish
            if ($Strings[$i][$j] -ne $Strings[0][$j]) {
                $MinLength = $j
                break
            }
        }
    }

    # Return the common prefix found in the first string up to the minimum length
    return $Strings[0].Substring(0, $MinLength)
}

