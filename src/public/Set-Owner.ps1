function Set-Owner {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$Owner = "BUILTIN\Administrators"

    )
    
    begin {
        #Validate Path
        if (-not (Test-Path -Path $Path)) {
            throw "The path $Path does not exist."
        }
        Test-IsAdmin
    }
    
    process {
        try {
            # Set Ownership of the folder to allow modification of permissions
            $NewOwner = New-Object System.Security.Principal.NTAccount($Owner)
            $ACL = Get-Acl -Path $Path
            $ACL.SetOwner($NewOwner)
            Write-Verbose "Setting owner of $HomeFolder to $NewOwner"
            $ACL.SetAccessRuleProtection($false, $false) # Don't break inheritence
            Set-Acl -Path $Path -AclObject $acl
        } catch {
            throw "Failed to set owner of $Path to $Owner. $_"
        }
    }
    
    end {
        
    }
}
