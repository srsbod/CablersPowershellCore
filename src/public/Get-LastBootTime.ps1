<#
.SYNOPSIS
Retrieves the last boot time of the local computer.

.DESCRIPTION
The Get-LastBootTime function uses CIM to query the Win32_OperatingSystem class and retrieves the last boot time of the local computer. 
The output is formatted as a human-readable date and time.

.EXAMPLE
PS C:\> Get-LastBootTime
15 October 2023 08:45:12

This example retrieves and displays the last boot time of the local computer.

#>
function Get-LastBootTime {
    [CmdletBinding()]
    param (
        
    )
    
    begin {

    }
    
    process {
        $LastBootTime = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime | Get-Date -Format "dd MMMM yyyy hh:mm:ss"
        Write-Output $LastBootTime
    }
    
    end {
        
    }
}


