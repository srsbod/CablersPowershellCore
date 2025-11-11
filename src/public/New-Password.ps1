#Requires -Module PwnedPassCheck

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

.PARAMETER NoProgress
Suppresses the progress bar display during password generation.

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
        [int]$SleepTime = 0, # In case it needs to be adjusted or increased to avoid rate limiting
        [Parameter(Mandatory = $false)]
        [switch]$NoProgress
    )

    begin {
        $Passwords = @()
        $GeneratedPasswords = 0
    }

    process {

        while ($GeneratedPasswords -lt $NumberOfPasswords) {

            if (-not $NoProgress) {
                $ProgressPercentage = [math]::Round(($GeneratedPasswords / $NumberOfPasswords) * 100)
                Write-Progress -Activity "Generating Passwords" -Status "$ProgressPercentage% Complete:" -PercentComplete $ProgressPercentage
            }

            if ($Simple) {
                $Password = Invoke-RestMethod -Uri "https://www.dinopass.com/password/simple"
            } elseif ($Strong) {
                $Password = Invoke-RestMethod -Uri "https://www.dinopass.com/password/strong"
            } elseif ($Random) {
                if ($NoSymbols) {
                    $Password = Invoke-RestMethod -Uri "https://api.genratr.com/?length=$Length&uppercase&lowercase&numbers" | Select-Object -ExpandProperty password
                } else {
                    $Password = Invoke-RestMethod -Uri "https://api.genratr.com/?length=$Length&uppercase&lowercase&special&numbers" | Select-Object -ExpandProperty password
                }
            }

            if ($PwnCheck) {
                $Pwned = Get-PwnedPassword $Password | Select-Object -ExpandProperty SeenCount
                if ($Pwned -gt 0) {
                    Write-Host "Password $Password is pwned, generating a new one instead - Pwned count: $Pwned" -ForegroundColor Yellow
                    continue
                }
            }

            $Passwords += $Password
            $GeneratedPasswords++


            # Sleep for a short period to avoid rate limiting
            Start-Sleep -Milliseconds $SleepTime
        }

        if ($OutputPath) {
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


