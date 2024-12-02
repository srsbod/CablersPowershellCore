#TODO: Consider changing command name
#TODO: Test multiple path input
#TODO: Add SupportsShouldProcess

<#

.SYNOPSIS
    Take or grant ownership of a file or folder.

.DESCRIPTION

    Take or grant ownership of a file or folder as the current user. Can accept Path from pipeline. Can accept multiple paths.

.PARAMETER Path

    The path(s) to the file or folder to take ownership of.

.PARAMETER Recurse

    If specified, the ownership will be applied to all files and subfolders in the specified path.

.PARAMETER Identity

    The user to take ownership as. Default is the current user.

.EXAMPLE

    Set-Ownership -Path "C:\Temp\test.txt"

    This will take ownership of the file test.txt as the current user.

.EXAMPLE

    Set-Ownership "C:\Temp" -Recurse

    This will take ownership of all files and folders in the C:\Temp directory as the current user.

.EXAMPLE

    $SomeFolder = "C:\Temp"
    $SomeFolder | Set-Ownership

    This will take ownership of the folder C:\Temp as the current user.

.EXAMPLE

    $SomeFolders = Get-ChildItem -Path "C:\Temp"
    $SomeFolders | Set-Ownership -Identity "Everyone"

    This will grant ownership of all files and folders in the C:\Temp directory to the Everyone group.

#>
function Set-Ownership {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [bool]$Recurse = $false,

        [string]$Identity = $env:USERNAME
    )

    begin {
        # Validate Path(s)
        foreach ($SinglePath in $Path) {
            if (-not (Test-Path -Path $SinglePath)) {
                Throw "Path does not exist: $SinglePath"
            }
        }
    }

    process {

        foreach ($SinglePath in $Path) {
            try {
                Write-Verbose "Taking ownership of path: $SinglePath"

                If ($PSCmdlet.ShouldProcess($SinglePath, "Set ownership to $Identity")) {
                    # Take ownership
                    $acl = Get-Acl -Path $SinglePath
                    $acl.SetOwner([System.Security.Principal.NTAccount]::new($Identity))
                    Set-Acl -Path $SinglePath -AclObject $acl

                    if ($Recurse) {
                        Try {
                            Get-ChildItem -Path $SinglePath -Recurse | ForEach-Object {
                                $acl = Get-Acl -Path $_.FullName
                                $acl.SetOwner([System.Security.Principal.NTAccount]::new($Identity))
                                Set-Acl -Path $_.FullName -AclObject $acl
                                Write-Verbose "Ownership taken successfully for path: $($_.FullName)"
                            }
                        }
                        Catch {
                            Write-Error "Failed to take ownership of path. $_"
                        }
                    }

                    # Verbose output
                    Write-Verbose "Ownership taken successfully for path: $SinglePath"
                }
                $acl = Get-Acl -Path $SinglePath
                $acl.SetOwner([System.Security.Principal.NTAccount]::new($Identity))
                Set-Acl -Path $SinglePath -AclObject $acl

                if ($Recurse) {
                    Try {
                        Get-ChildItem -Path $SinglePath -Recurse | ForEach-Object {
                            $acl = Get-Acl -Path $_.FullName
                            $acl.SetOwner([System.Security.Principal.NTAccount]::new($Identity))
                            Set-Acl -Path $_.FullName -AclObject $acl
                            Write-Verbose "Ownership taken successfully for path: $($_.FullName)"
                        }
                    }
                    Catch {
                        Write-Error "Failed to take ownership of path. $_"
                    }
                }

                # Verbose output
                Write-Verbose "Ownership taken successfully for path: $SinglePath"
            }
            catch {
                # Error handling
                Write-Error "Failed to take ownership of path: $SinglePath. $_"
            }
        }
    }

    end {
        # Cleanup code goes here
    }
}
