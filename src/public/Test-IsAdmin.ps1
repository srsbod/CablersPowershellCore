<#
.SYNOPSIS
    Tests if the current user has administrative privileges.

.DESCRIPTION
    This function checks whether the current PowerShell session is running with administrative privileges.
    It works across both Windows PowerShell and PowerShell Core.

.PARAMETER None
    This function does not accept any parameters.

.OUTPUTS
    [Boolean] Returns $True if the current user has administrative privileges, $False otherwise.

.EXAMPLE
    Test-IsAdmin
    Returns $True if the script is run as administrator, $False otherwise.
#>
function Test-IsAdmin {
    [CmdletBinding()]
    param()
    
    # Get the current Windows identity
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        
    # Create a Windows principal object
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
        
    # Check if the current principal has administrative rights
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        
    # Write-Output $isAdmin

    if ($isAdmin -eq $false) {
        return $false
    } else {
        return $true
    }

}
