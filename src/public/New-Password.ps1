#Requires -Module PwnedPassCheck

#TODO: Support for passphrases?
#TODO: Test rate limiting better, possibly reduce/remove it to speed up the process

<#
.SYNOPSIS
Generates one or more passwords based on the specified parameters.

.DESCRIPTION
The New-Password function generates passwords using different methods such as simple, strong, or random. 
It supports additional options like checking if the password has been pwned, saving to a file, or copying to the clipboard.

.PARAMETER Simple
Generates a simple password using an external API.

.PARAMETER Strong
Generates a strong password using an external API.

.PARAMETER Random
Generates a random password with customizable length and character set.

.PARAMETER Length
Specifies the length of the random password. Default is 12.

.PARAMETER NoSymbols
Excludes symbols from the random password.

.PARAMETER PwnCheck
Checks if the generated password has been pwned using the PwnedPassCheck module.

.PARAMETER NumberOfPasswords
Specifies the number of passwords to generate. Default is 1.

.PARAMETER OutputPath
Specifies the file path to save the generated passwords.

.PARAMETER CopyToClipboard
Copies the generated passwords to the clipboard.

.PARAMETER SleepTime
Specifies the delay (in milliseconds) between password generations to avoid rate limiting. Default is 100.

.EXAMPLE
New-Password -Simple -NumberOfPasswords 5

Generates 5 simple passwords.

.EXAMPLE
New-Password -Random -Length 16 -NoSymbols -PwnCheck

Generates a random password of length 16 without symbols and checks if it has been pwned.

.EXAMPLE
New-Password -Strong -OutputPath "C:\Passwords.txt"

Generates a strong password and saves it to the specified file.

.NOTES
Requires the PwnedPassCheck module for the PwnCheck functionality.
#>
function New-Password {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "Not actually changing anything on the system.")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Write-Host is fine here.")]
    [CmdletBinding(DefaultParameterSetName = "Simple")]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Simple")]
        [switch]$Simple,
        [Parameter(Mandatory = $true, ParameterSetName = "Strong")]
        [switch]$Strong,
        [Parameter(Mandatory = $true, ParameterSetName = "Random")]
        [switch]$Random,
        [Parameter(mandatory = $false, ParameterSetName = "Random")]
        [int]$Length = 12,
        [Parameter(Mandatory = $false, ParameterSetName = "Random")]
        [Switch]$NoSymbols,
        [Parameter(Mandatory = $false)]
        [Switch]$PwnCheck,
        [Parameter(Mandatory = $false)]
        [int]$NumberOfPasswords = 1,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,
        [Parameter(Mandatory = $false)]
        [Switch]$CopyToClipboard,
        [Parameter(Mandatory = $false)]
        [int]$SleepTime = 100 # In case it needs to be adjusted or increased to avoid rate limiting
    )

    begin {
        $Passwords = @()
        $GeneratedPasswords = 0
    }

    process {

        while ($GeneratedPasswords -lt $NumberOfPasswords) {

            $ProgressPercentage = [math]::Round(($GeneratedPasswords / $NumberOfPasswords) * 100)
            Write-Progress -Activity "Generating Passwords" -Status "$ProgressPercentage% Complete:" -PercentComplete $ProgressPercentage

            if ($Simple) {
                $Password = Invoke-RestMethod -Uri "https://www.dinopass.com/password/simple"
            }
            elseif ($Strong) {
                $Password = Invoke-RestMethod -Uri "https://www.dinopass.com/password/strong"
            }
            elseif ($Random) {
                If ($NoSymbols) {
                    $Password = Invoke-RestMethod -Uri "https://api.genratr.com/?length=$Length&uppercase&lowercase&numbers" | Select-Object -ExpandProperty password
                }
                else {
                    $Password = Invoke-RestMethod -Uri "https://api.genratr.com/?length=$Length&uppercase&lowercase&special&numbers" | Select-Object -ExpandProperty password
                }
            }

            if ($PwnCheck) {
                $Pwned = Get-PwnedPassword $Password | Select-Object -ExpandProperty SeenCount
                if ($Pwned -gt 0) {
                    Write-Host "Password $Password is pwned, generating a new one instead - Pwned count: $Pwned" -ForegroundColor Yellow
                    Continue
                }
            }

            $Passwords += $Password
            $GeneratedPasswords++


            # Sleep for a short period to avoid rate limiting
            Start-Sleep -Milliseconds $SleepTime
        }

        If ($OutputPath) {
            $Passwords | Out-File $OutputPath -Append -Force
        }

        if ($CopyToClipboard) {
            $Passwords | Set-Clipboard
        }

        Write-Output $Passwords
    }

    end {

    }
}

# SIG # Begin signature block
# MIIbvwYJKoZIhvcNAQcCoIIbsDCCG6wCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAPjj63TEDne6iy
# akdXmnGqBWPG+EQAUmlnnhFwEyFZD6CCFg8wggMIMIIB8KADAgECAhAaoCcGjnb0
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEiBCCBzCay
# +wh2WvjmmJeoXjFbomirDiud/wNU+nrVxpwLczANBgkqhkiG9w0BAQEFAASCAQAx
# zrmhVZyJxxAZjvM7H4kX7bTTbzqbONbTY1Qg+oW7PLKKJzHYWmv9j8P8nsAaSkwL
# frnAU+WNCo8QNlKe3MUn7WljgNBP6vzC3/juIWLtI/B741uYivfoZOVxNh5LaFaK
# 7CtDy4+Z/dFOe0bKnsPtHZedws/TPPn7kt8hlIIX7eRwuwjI9UQ2er2UVTaXkCp4
# 7vKqxCzI4u0PDD7z782l1VwrMW5pOh/G2/X8b5XIWQPNA+08GHYc2RrRrTCAwfve
# t4uMOaj716O9X0GqKI1AFTyWPWCE6zxCteLM417gfKah956VIgVD7j0tLRq+u4dU
# MHXFylee0Fj9ViYw5Rv/oYIDIDCCAxwGCSqGSIb3DQEJBjGCAw0wggMJAgEBMHcw
# YzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQD
# EzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGlu
# ZyBDQQIQC65mvFq6f5WHxvnpBOMzBDANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3
# DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI1MDMyMTExMTIyM1ow
# LwYJKoZIhvcNAQkEMSIEII5MJSVo/0iwlKRPYndrVZ4YFqwIkqju8itAG5wxDdeB
# MA0GCSqGSIb3DQEBAQUABIICAKByJ6ZJdqyPwhS1A3naOo0qgRPrwvfrIfRUfa9u
# /zNbjKCKTfAl21CqFhJvAy7Wiq1b59c7HUws1gKwbGUjjkZwBcAhnj3B6idUcjpN
# RzkwBMQKLJIs+ykFULBemL9Gclc21Y8ocjxWuQyAsbuTu82YNBwGl0J+4nfUWFhy
# 9/BH3NE2nbtnb6c1Lp5bXQcRtzvmvx5yQJulqqkiG2RcX8q15898Jd4RO93MwmaR
# B1owlNUgn7ruFw375MRaHWGslH6dpSTN/yz1V6enf09LZ0uMMiGM7Ucvmpa6zhH4
# qh35viCCCr+laTM83ZYfW8vcEd1o69j2EsNWR3uvz/UX//yxKIhv2PJEF7kIj/fG
# lTuG13J7HBOVFcYxOQnoW4gQc2D/gLNEsZKK0ThNiBi7YFuGlxxGdFrzpVrLyI/k
# VAV3hnOt6JK/x3mi5FlsKhUA47qkZJVEnr2MUK6U4+Ctt1g/GYWMlvOFESBjpEvr
# 4odbG8juj8/fW7z8g49cDl8qcPKW+wZBrBYnavh+gCMBNn2BUHw6mZVvDzEaGDmN
# ifG81KdpWjnxh5Bi27q6P1zubZpER9Np4vBw1aHhmhh8rvWN2Jky7B0nzvTyNuXi
# 1RSCuYTPqvuW/IV7yFr9VEXMQ0N2nzn3L8/cPr2Qqn9SLGHBGj/PBJGONnw8VAVE
# EL31
# SIG # End signature block
