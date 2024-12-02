<#

.SYNOPSIS
    Get the uptime of the local machine.

.DESCRIPTION
    Get the uptime of the local machine. Returns a custom object with the last reboot time and the uptime in the format dd.HH:mm:ss by default.
    Switch parameters can be used to display the uptime in days, minutes, hours, or seconds.

.PARAMETER Days
    Display the number of full days the machine has been up.

.PARAMETER Hours
    Display the number of full hours the machine has been up. For example a device online for 2 days will return 48

.PARAMETER Minutes
    Display the number of full minutes the machine has been up.

.PARAMETER Seconds
    Display the number of full seconds the machine has been up.


.EXAMPLE
    Get-Uptime

    Returns the last reboot time and the uptime in the format dd.HH:mm:ss.

.EXAMPLE
    Get-Uptime -Days

    Returns the number of full days the machine has been up.

.EXAMPLE

    Get-Uptime -Hours

    Returns the number of full hours the machine has been up.

#>


If (-not (Get-Command Get-Uptime -ErrorAction SilentlyContinue)) {
    function Get-Uptime {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidOverwritingBuiltInCmdlets", "", Justification = "Only loads in powershell 5.1.")]
        [CmdletBinding()]
        param(
            [Parameter()]
            [Switch]$Since
        )

        $LastBootTime = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime | Get-Date -Format "dd MMMM yyyy hh:mm:ss"
        $Today = Get-Date
        $Uptime = $Today.Date - (Get-Date $LastBootTime)

        If ($Since) {
            Return $LastBootTime
        }
        else {
            Return $Uptime
        }

    }
}
