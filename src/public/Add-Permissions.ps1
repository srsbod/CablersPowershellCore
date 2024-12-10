#TODO: I don't think this works on folders, only on files. May need to test and use a different Set-ACL command (containerinherit,objectinherit) for folders
#TODO: Test pipeline input
#TODO: Test multiple identities
#TODO: Test multiple paths
#TODO: May need to split out recurse into objectinherit and containerinherit, probably still keep recurse to do both as it's more intuitive, just need to validate it correctly (i.e. if recurse is specified with another, just use recurse)

<#

.SYNOPSIS

    Add permissions to a file or folder.

.DESCRIPTION

    Add permissions to a file or folder. Can accept an array of paths and or identities

.SYNTAX

    Add-Permissions [-Path] <string[]> [-Identity] <string[]> [-Permission {FullControl | Modify | Read | Write}] [-Type {Allow | Deny}] [-Recurse] [<CommonParameters>]

.PARAMETER Path

    [string[]]
    The path(s) to the file(s) or folder(s) to add permissions to.

.PARAMETER Identity

    [string[]]
    The user(s) or group(s) to add permissions for.

.PARAMETER Recurse

    [Switch]
    If specified, the permissions will be applied to all files and folders in the specified path.

.PARAMETER Permission

    [string]
    The permission to add. Default is FullControl.
    Options are: FullControl, Modify, Read, Write

.PARAMETER Type

    [string]
    The type of permission to add. Default is Allow.
    Options are: Allow, Deny

.EXAMPLE
    Add-Permissions -Path "C:\Temp\test.txt" -Identity "Everyone" -Permission "Read" -Type "Allow"
    This will add read permissions for the Everyone group to the file test.txt.

.EXAMPLE
    Add-Permissions "C:\Temp" -Identity "Everyone" -Permission "Read" -Type "Allow" -Recurse
    This will add read permissions for the Everyone group to all files and folders in the C:\Temp directory.

.EXAMPLE
    $SomeFolder = "C:\Temp"
    $SomeFolder | Add-Permissions -Identity "Everyone" -Permission "Read" -Type "Deny" -Recurse
    This will deny read permissions for Everyone to all files and folders in the C:\Temp directory.
    Definitely do not do this!

.EXAMPLE
    $SomeFolders = Get-ChildItem -Path "C:\Temp"
    $SomeFolders | Add-Permissions -Identity "Everyone" -Permission "Modify" -Type "Allow"
    This will add modify permissions for Everyone to all files and folders in the C:\Temp directory.

.EXAMPLE
    $SomeUsers = "User1", "User2", "User3"
    Add-Permissions -Path "C:\Temp" -Identity $SomeUsers -Permission "Write" -Type "Deny" -Recurse
    This will deny write permissions for User1, User2, and User3 to all files and folders in the C:\Temp directory.

.NOTES

    None

.OUTPUTS

    Object with the following properties:
    - Type
    - Permission
    - Recurse
    - User
    - Path

#>
function Add-Permissions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Identity,

        [Parameter()]
        [Switch]$Recurse,

        [Parameter()]
        [ValidateSet("FullControl", "Modify", "Read", "Write")]
        [string]$Permission = "FullControl",

        [Parameter()]
        [ValidateSet("Allow", "Deny")]
        [string]$Type = "Allow"
    )

    Begin {
        If (-not (Test-Path -Path $Path)) {
            Throw "Path does not exist: $Path"
        }
    }

    Process {
        try {
            foreach ($SinglePath in $Path) {
                $acl = Get-Acl -Path $SinglePath
                foreach ($user in $Identity) {
                    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, $Permission, $Type)
                    $acl.AddAccessRule($accessRule)
                    $Obj = [PSCustomObject]@{
                        Type       = $Type
                        Permission = $Permission
                        Recurse    = $Recurse
                        User       = $user
                        path       = $SinglePath
                    }

                    Write-Verbose $Obj
                }

                if ($Recurse) {
                    $acl | Set-Acl -Path $SinglePath
                }
                else {
                    $acl | Set-Acl -Path $SinglePath
                }
            }
        }
        catch {
            Write-Error "An error occurred while setting permissions: $_"
        }

    }

    End {
        Return $Obj
    }
}
