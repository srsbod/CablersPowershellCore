#TODO: Comment based help
#TODO: Add parameter to filter for specific drive
#TODO: Add parameter for simple output (e.g. "C:\ - 86 GB of 200 GB (40%) remaining")

Function Get-DiskSpace {
    [CmdletBinding()]
    param (
    )

    Begin {

    }

    Process {


        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[A-Z]:\\$" -and $null -eq $_.displayroot }
        $output = @()

        foreach ($drive in $drives) {
            $FreeSpace = $drive.Free / 1GB
            $TotalSpace = ($drive.Used + $drive.Free) / 1GB
            $UsedSpace = $drive.Used / 1GB
            #$Output += "$($drive.Name):\ - $($FreeSpace.ToString('0')) GB of $($TotalSpace.ToString('0')) GB remaining"
            $Output += [PSCustomObject]@{
                Drive       = $Drive.Name
                UsedSpace   = "$($UsedSpace.ToString('0')) GB"
                FreeSpace   = "$($FreeSpace.ToString('0')) GB"
                TotalSpace  = "$($TotalSpace.ToString('0')) GB"
                PercentUsed = "{0:P2}" -f ($UsedSpace / $TotalSpace)
                PercentFree = "{0:P2}" -f ($FreeSpace / $TotalSpace)
            }
        }

        return $Output

    }

    End {

    }

}
