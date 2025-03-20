<#
.SYNOPSIS
    Retrieves disk space information for specified drives.

.DESCRIPTION
    This function retrieves disk space information for all drives or specified drives on a Windows system.
    It provides details such as used space, free space, total space, and percentage used.

.PARAMETER DriveLetter
    Specifies the drive letters to retrieve information for. If not specified, all drives are included.

.PARAMETER Simple
    Outputs the disk space information as a simple string instead of a detailed object.

.EXAMPLE
    Get-DiskSpace
    Retrieves disk space information for all drives.

.EXAMPLE
    Get-DiskSpace -DriveLetter "C", "D"
    Retrieves disk space information for drives C and D.

.EXAMPLE
    Get-DiskSpace -Simple
    Retrieves disk space information in a simple string format.

#>
Function Get-DiskSpace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DriveLetter = $null,
        [Parameter(Mandatory = $false)]
        [switch]$Simple = $false
    )

    Begin {
        
        if ($PSVersionTable.Platform -ne 'Win32NT') {
            Throw "This function is only supported on Windows platforms."
        }

        # Format the drive letters as a single uppercase letter, remove any duplicates and remove any : or \ characters
        if ($DriveLetter) {
            $DriveLetter = $DriveLetter | ForEach-Object { $_.ToUpper() -replace '[^A-Z]', '' } | Sort-Object -Unique
        }

        # If the drive letter is not in the correct format then user has passed something wrong, throw an error
        if ($DriveLetter) {
            foreach ($letter in $DriveLetter) {
                if ($letter.Length -ne 1 -or $letter -notmatch '^[A-Z]$') {
                    Throw "Invalid drive letter: $letter - Drive letters must be in format 'C', 'C:', or 'C:\'"
                }
            }
        }
    }

    Process {


        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[A-Z]:\\$" -and $null -eq $_.displayroot }
        $output = @()

        If ($DriveLetter) {
            $drives = $drives | Where-Object { $DriveLetter -contains $_.Name }
        }

        foreach ($drive in $drives) {

            $FreeSpace = $drive.Free / 1GB
            $TotalSpace = ($drive.Used + $drive.Free) / 1GB
            $UsedSpace = $drive.Used / 1GB
            $PercentUsed = "{0:P1}" -f ($UsedSpace / $TotalSpace)
            $PercentFree = "{0:P1}" -f ($FreeSpace / $TotalSpace)

            if ($Simple) {
                $Output += "$($drive.Root) - $($UsedSpace.ToString('0')) GB of $($TotalSpace.ToString('0')) GB used, $($FreeSpace.ToString('0')) GB ($($PercentFree.ToString())) remaining"
            }
            else {
                $Output += [PSCustomObject]@{
                    Drive       = $Drive.Root
                    UsedSpace   = "$($UsedSpace.ToString('0')) GB"
                    FreeSpace   = "$($FreeSpace.ToString('0')) GB"
                    TotalSpace  = "$($TotalSpace.ToString('0')) GB"
                    PercentUsed = $PercentUsed
                    PercentFree = $PercentFree
                }
            }
        }

        return $Output

    }

    End {

    }

}
