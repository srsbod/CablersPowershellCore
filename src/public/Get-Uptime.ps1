<# 
.SYNOPSIS
    Calculate the uptime of the local machine.

.DESCRIPTION
    This function calculates the uptime of the local machine by determining the difference between the current date and the last boot time.
    It returns the uptime as a timespan object.

.EXAMPLE
    Get-Uptime

    Returns the uptime of the local machine as a timespan object.

.NOTES
    This function is only available in Windows PowerShell (not PowerShell Core) since PowerShell Core already has this Cmdlet built in.
#>

If ($PSVersionTable.PSEdition -eq 'Core') {
    return
}

function Get-Uptime {
    [CmdletBinding()]
    param()

    $LastBootTime = Get-Date (Get-LastBootTime)
    $CurrentTime = Get-Date

    # Debugging information
    Write-Debug "Last Boot Time: $LastBootTime"
    Write-Debug "Current Time: $CurrentTime"

    # Calculate uptime
    $Uptime = $CurrentTime - $LastBootTime
    Write-Debug "Uptime: $Uptime"

    # Output the uptime
    Write-Output $Uptime
}
