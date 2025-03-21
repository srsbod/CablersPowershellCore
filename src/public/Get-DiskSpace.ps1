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

        Write-Output $Output

    }

    End {

    }

}

# SIG # Begin signature block
# MIIbvwYJKoZIhvcNAQcCoIIbsDCCG6wCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBuoL4Ct13+7ppI
# nNpCqB2WPh+0C5O6ukwyHHFBxCZ+0KCCFg8wggMIMIIB8KADAgECAhAaoCcGjnb0
# u02vILE9ukKJMA0GCSqGSIb3DQEBCwUAMBwxGjAYBgNVBAMMEUNhYmxlcnNQb3dl
# cnNoZWxsMB4XDTI1MDMyMTA5NTE1MVoXDTI4MDMyMTEwMDE1MVowHDEaMBgGA1UE
# AwwRQ2FibGVyc1Bvd2Vyc2hlbGwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQDG/hOjUOqrniLXGRxDcrqbVSHv1fGNU/0VoiIg99jaYuCokVTJlYgDyIa+
# ONYcbtIllg7HCYv3dJb44x9CrliYUwNCN4PVN8ZqgJc2XtrZ9nvqSyAwRWOs610T
# OYldffQ1SlP2aAx21UHaZsmMhb4eoBosigqz4g99DDLMiw5q6CnmZ+3N2NUxZObr
# pAOZqnPetAVhTG+hdI3GF9Kf6lPtfTkXWlkjGyb93+OJVn/3mFJEpcDVrCOxgcqq
# mJzfKkQ8HfJ8v+Y66ASZblKNf/FwrqqsldTwiCIvPjB39HaJqkNo63iSpwU211oQ
# gl5AwMy1LVaO26zCBzVrx7AxrfNpAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDAT
# BgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU+YBrQkSyP0fSZ4JojMZWNppx
# iFgwDQYJKoZIhvcNAQELBQADggEBAB0Xvons76/DzhM/HnN5Kt/8TnP/X8O8BsSp
# 13oAesIsC35IIYPQmq5/IeKHTwcSW9G6L1AG83WENGsMYgsHG5YL9lLGp5PnFY3R
# asDcSjP8ziDqzRdrKAL/iAAdyv0yHGCQIpz9DZn9dQmPATEV16cfqVG2Sx+GOxJ0
# 9pUy+qfPpC/sGOoj+VfT6M1CJ3Wt4GZ0hX2CHtQl63vDu8nlGyOjWZKsdiiYHvJ0
# hXyjuTqV87OC2VKxrn83a1Ulf1OZERGlRV5RCeyTvHGZEMoEGBJ7rz3d7HypWb1a
# WDjvOY4YoYGoqXUN2kUKjPdPZ6R14e/C6G73mP/grdx+ikXfawgwggWNMIIEdaAD
# AgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0y
# MjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAf
# BgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4Smn
# PVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6f
# qVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O
# 7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZ
# Vu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4F
# fYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLm
# qaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMre
# Sx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/ch
# srIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+U
# DCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xM
# dT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUb
# AgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFd
# ZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAO
# BgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0f
# BD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNz
# dXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEM
# BQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLt
# pIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouy
# XtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jS
# TEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAc
# AgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2
# h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQwggauMIIElqADAgECAhAHNje3JFR82Ees
# /ShmKl5bMA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMT
# GERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAz
# MjIyMzU5NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBU
# aW1lU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDG
# hjUGSbPBPXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6
# ffOciQt/nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/
# qxkrPkLcZ47qUT3w1lbU5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3Hxq
# V3rwN3mfXazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVj
# bOSmxR3NNg1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcp
# licu9Yemj052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZ
# girHkr+g3uM+onP65x9abJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZG
# s506o9UD4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHz
# NklNiyDSLFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2
# ElGTyYwMO1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJ
# ASgADoRU7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYD
# VR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8w
# HwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGG
# MBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBD
# BgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRUcnVzdGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgB
# hv1sBwEwDQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4Q
# TRPPMFPOvxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfN
# thKWb8RQTGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1g
# tqpPkWaeLJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1Ypx
# dmXazPByoyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/um
# nXKvxMfBwWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+U
# zTl63f8lY5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhz
# q6YBT70/O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11
# LB4nLCbbbxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCY
# oCvtlUG3OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvk
# dgIm2fBldkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3
# OBqhK/bt1nz8MIIGvDCCBKSgAwIBAgIQC65mvFq6f5WHxvnpBOMzBDANBgkqhkiG
# 9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4x
# OzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGlt
# ZVN0YW1waW5nIENBMB4XDTI0MDkyNjAwMDAwMFoXDTM1MTEyNTIzNTk1OVowQjEL
# MAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSAwHgYDVQQDExdEaWdpQ2Vy
# dCBUaW1lc3RhbXAgMjAyNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AL5qc5/2lSGrljC6W23mWaO16P2RHxjEiDtqmeOlwf0KMCBDEr4IxHRGd7+L660x
# 5XltSVhhK64zi9CeC9B6lUdXM0s71EOcRe8+CEJp+3R2O8oo76EO7o5tLuslxdr9
# Qq82aKcpA9O//X6QE+AcaU/byaCagLD/GLoUb35SfWHh43rOH3bpLEx7pZ7avVnp
# UVmPvkxT8c2a2yC0WMp8hMu60tZR0ChaV76Nhnj37DEYTX9ReNZ8hIOYe4jl7/r4
# 19CvEYVIrH6sN00yx49boUuumF9i2T8UuKGn9966fR5X6kgXj3o5WHhHVO+NBikD
# O0mlUh902wS/Eeh8F/UFaRp1z5SnROHwSJ+QQRZ1fisD8UTVDSupWJNstVkiqLq+
# ISTdEjJKGjVfIcsgA4l9cbk8Smlzddh4EfvFrpVNnes4c16Jidj5XiPVdsn5n10j
# xmGpxoMc6iPkoaDhi6JjHd5ibfdp5uzIXp4P0wXkgNs+CO/CacBqU0R4k+8h6gYl
# dp4FCMgrXdKWfM4N0u25OEAuEa3JyidxW48jwBqIJqImd93NRxvd1aepSeNeREXA
# u2xUDEW8aqzFQDYmr9ZONuc2MhTMizchNULpUEoA6Vva7b1XCB+1rxvbKmLqfY/M
# /SdV6mwWTyeVy5Z/JkvMFpnQy5wR14GJcv6dQ4aEKOX5AgMBAAGjggGLMIIBhzAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEF
# BQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgw
# FoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFJ9XLAN3DigVkGalY17u
# T5IfdqBbMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5j
# cmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcnQwDQYJKoZIhvcNAQELBQADggIBAD2tHh92mVvjOIQSR9lDkfYR25tOCB3R
# KE/P09x7gUsmXqt40ouRl3lj+8QioVYq3igpwrPvBmZdrlWBb0HvqT00nFSXgmUr
# DKNSQqGTdpjHsPy+LaalTW0qVjvUBhcHzBMutB6HzeledbDCzFzUy34VarPnvIWr
# qVogK0qM8gJhh/+qDEAIdO/KkYesLyTVOoJ4eTq7gj9UFAL1UruJKlTnCVaM2UeU
# UW/8z3fvjxhN6hdT98Vr2FYlCS7Mbb4Hv5swO+aAXxWUm3WpByXtgVQxiBlTVYzq
# fLDbe9PpBKDBfk+rabTFDZXoUke7zPgtd7/fvWTlCs30VAGEsshJmLbJ6ZbQ/xll
# /HjO9JbNVekBv2Tgem+mLptR7yIrpaidRJXrI+UzB6vAlk/8a1u7cIqV0yef4uaZ
# FORNekUgQHTqddmsPCEIYQP7xGxZBIhdmm4bhYsVA6G2WgNFYagLDBzpmk9104WQ
# zYuVNsxyoVLObhx3RugaEGru+SojW4dHPoWrUhftNpFC5H7QEY7MhKRyrBe7ucyk
# W7eaCuWBsBb4HOKRFVDcrZgdwaSIqMDiCLg4D+TPVgKx2EgEdeoHNHT9l3ZDBD+X
# gbF+23/zBjeCtxz+dL/9NWR6P2eZRi7zcEO1xwcdcqJsyz/JceENc2Sg8h3KeFUC
# S7tpFk7CrDqkMYIFBjCCBQICAQEwMDAcMRowGAYDVQQDDBFDYWJsZXJzUG93ZXJz
# aGVsbAIQGqAnBo529LtNryCxPbpCiTANBglghkgBZQMEAgEFAKCBhDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEiBCCrGrN1
# iD3Bw3LIVoYgQjj9L7DMAgJ19kvuG4icXlti5zANBgkqhkiG9w0BAQEFAASCAQBD
# jDcEBTTHFUiN4g6GbW5ChFPzFoHxL5YQOE/FXxvbNlIejOZmfutnc/5KouUt6kMG
# tFFj6SiTg2gPgIfc7nbqXjeRU69oRbeE5jpfQ9cX2vIVATqbPXMUVgM6PxfoHX8B
# CU1MbYUwQKp4suOuBeSO2xpsUxMDN5sqiibn7aVGGPsYQX51hGNm55m32mWCewNZ
# v1gebueWE1YDjnDqeZsRZh7M7TEn2SN8gXyxOWifhJXIHeeCcZzaCDsIvMtLIx3b
# TYT57Fiff1uokt14NKWhdcxbAqZ/bmGlAodcZUXVR27MNpU6+6YZ2yTtLtldoqyA
# r+MPsdR1tTyuToHGuuiloYIDIDCCAxwGCSqGSIb3DQEJBjGCAw0wggMJAgEBMHcw
# YzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQD
# EzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGlu
# ZyBDQQIQC65mvFq6f5WHxvnpBOMzBDANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3
# DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI1MDMyMTExMTIyM1ow
# LwYJKoZIhvcNAQkEMSIEILgXUM/OM31yEL/1jj8sgGJ0hMahWXxTkQphPFq83n1G
# MA0GCSqGSIb3DQEBAQUABIICAFhdPL78ItXuYEL5xTF64CKC2bvq2FR5sim0/Ux7
# DMUtvxMSvUrXwBgHsEElXTh/01rA5Ypzyf0EDSs+ewjSCPDmuCHTpNcpKB/0OBJ7
# gr6abd5QX1MPafBymMdxMu+Z8RyXlLFEqlrH0SV+hO8d+y2X/amAtzddNb0tKmhD
# MVrIFP8UD0E2eeofkEx9DiRhuyMUCwloS0LJNz/CIHQRgC4Aup5fb4GwH+ABTNGy
# qUUgS+wy1JdGk+/jEcX+V6VTfTw4LfkZtZMaRJvz+HiIk6xnCskaRteuE+Yu6/B7
# ZTHKO211Yp72P9f7Mi6ZTao9v8OyBFgQBwy5rG8zYrD+gEEnweEjZXJg76soajiw
# Cw5aEsRaCbgs9aQ8ygo3qSjdVXF8SUB2F5dPY/yW+lhJ/bbxJw60NrAZVVG8TRt2
# rGLDexAZa7q5o/XZ5jomJvVk74Z+u+8X8zsXVcM478JD6djvIz1LdNT64Q1xyOVy
# ngyAh2LMc01S6fjkYfRtKylwoFiEOBkDgoKC8TmMOOGLRKgPPZlGFlGGPeamH3zo
# iWsTYvm6ywojL9T3Pqrfbk7abV+xSjfqf4b5Ic4YDIbq0iSios5CR9gtZhI29C5/
# hP4iew6DiBL5YzNgmewFkc0o2mbt9f0AkopbBG6InjFE3VcTPNEScqrxL3G77wPr
# QrY5
# SIG # End signature block
