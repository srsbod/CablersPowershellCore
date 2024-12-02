#Requires -Module PwnedPassCheck

#TODO: Comment based help
#TODO: Support for passphrases?
#TODO: Test rate limiting better, possibly reduce/remove it to speed up the process

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

        Return $Passwords
    }

    end {

    }
}
