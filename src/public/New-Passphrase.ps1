#Requires -Module PwnedPassCheck

#TODO: Additional format options (word##word, wordword##!)
#TODO: Add maximum and minimum word lengths to filter the word list

<#
.SYNOPSIS
Generates one or more passphrases based on the specified parameters.

.DESCRIPTION
The New-Passphrase function generates memorable passphrases by randomly selecting words from a word list 
and combining them with separators and optional numbers. It supports customizable word count, separator 
characters, case formatting, and optional pwned password checking.

.PARAMETER WordCount
Specifies the number of words to include in the passphrase. Default is 3.
Alias: Words

.PARAMETER Separator
Specifies the character used to separate words in the passphrase. Valid values: "-", "_", "None", ".", ",", "+", "=". Default is "-".

.PARAMETER Case
Specifies the case formatting for words in the passphrase. Valid values: "Lowercase", "Uppercase", "Titlecase", "RandomCase", "RandomLetter". Default is "Titlecase".
- Lowercase: All words in lowercase
- Uppercase: All words in UPPERCASE
- Titlecase: First letter uppercase, rest lowercase
- RandomCase: Each word is randomly uppercase or lowercase
- RandomLetter: Each letter in each word is randomly upper or lowercase

.PARAMETER ExcludeNumbers
Excludes numbers from the end of the passphrase. By default, a random number (0-99) is appended.

.PARAMETER PwnCheck
Checks if the generated passphrase has been pwned using the PwnedPassCheck module. If pwned, generates a new passphrase.

.PARAMETER NumberOfPassphrases
Specifies the number of passphrases to generate. Default is 1.
Alias: Count

.PARAMETER OutputPath
Specifies the file path to save the generated passphrases. If specified, passphrases are appended to the file, or a new file is created if it doesn't exist.

.PARAMETER CopyToClipboard
Copies the generated passphrases to the clipboard.

.PARAMETER NoProgress
Suppresses the progress bar display during passphrase generation.

.EXAMPLE
New-Passphrase

Generates a single passphrase with 3 titlecase words separated by hyphens and a random number at the end.

.EXAMPLE
New-Passphrase -WordCount 4 -Separator "_" -Case Uppercase -ExcludeNumbers

Generates a passphrase with 4 uppercase words separated by underscores without numbers.

.EXAMPLE
New-Passphrase -NumberOfPassphrases 5 -PwnCheck -OutputPath "C:\Passphrases.txt"

Generates 5 passphrases, checks if they've been pwned, and saves them to the specified file.

.EXAMPLE
New-Passphrase -Case RandomLetter -Separator "None" -CopyToClipboard

Generates a passphrase where each letter has random capitalization without separators and copies it to the clipboard.

.NOTES
Requires the PwnedPassCheck module for the PwnCheck functionality.
Word list is retrieved from https://raw.githubusercontent.com/srsbod/PassPhraseWordList/refs/heads/main/en.txt
#>
function New-Passphrase {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification = "Not actually changing anything on the system.")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Write-Host is fine here.")]
    [CmdletBinding(DefaultParameterSetName = "Simple")]
    param (
        [Parameter(Mandatory = $false)]
        [Alias("Words")]
        [int]$WordCount = 3,
        [Parameter(Mandatory = $false)]
        [ValidateSet("-", "_", "None", ".", ",", "+", "=")]
        [string]$Separator = "-",
        [Parameter(Mandatory = $false)]
        [ValidateSet("Lowercase", "Uppercase", "Titlecase", "RandomCase", "RandomLetter")]
        [string]$Case = "RandomCase",
        [Parameter(Mandatory = $false)]
        [switch]$ExcludeNumbers,
        [Parameter(Mandatory = $false)]
        [Switch]$PwnCheck,
        [Parameter(Mandatory = $false)]
        [Alias("Count")]
        [int]$NumberOfPassphrases = 1,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,
        [Parameter(Mandatory = $false)]
        [Switch]$CopyToClipboard,
        [Parameter(mandatory = $false)]
        [switch]$NoProgress
    )

    begin {
        $Passphrases = @()
        $GeneratedPassphrases = 0
        $WordListURL = "https://raw.githubusercontent.com/srsbod/PassPhraseWordList/refs/heads/main/en.txt"
        try {
            $WordList = (Invoke-RestMethod -Uri $WordListURL) -split "`n" | Where-Object { $_.Trim() -ne "" }
        } catch {
            Write-Error "Failed to retrieve word list from $WordListURL"
            exit 1
        }
    }

    process {

        while ($GeneratedPassphrases -lt $NumberOfPassphrases) {

            if (-not $NoProgress) {
                $ProgressPercentage = [math]::Round(($GeneratedPassphrases / $NumberOfPassphrases) * 100)
                Write-Progress -Activity "Generating Passphrases" -Status "$ProgressPercentage% Complete:" -PercentComplete $ProgressPercentage
            }
            
            $Words = @()
            for ($i = 0; $i -lt $WordCount; $i++) {
                $RandomWord = Get-Random -InputObject $WordList
                switch ($Case) {
                    "Lowercase" { $RandomWord = $RandomWord.ToLower() }
                    "Uppercase" { $RandomWord = $RandomWord.ToUpper() }
                    "Titlecase" { $RandomWord = ($RandomWord.Substring(0, 1).ToUpper() + $RandomWord.Substring(1).ToLower()) }
                    "RandomCase" {
                        if ((Get-Random -Minimum 0 -Maximum 2) -eq 1) {
                            $RandomWord = $RandomWord.ToUpper()
                        } else {
                            $RandomWord = $RandomWord.ToLower()
                        }
                    }
                    "RandomLetter" {
                        $RandomLetters = @()
                        foreach ($char in $RandomWord.ToCharArray()) {
                            if ((Get-Random -Minimum 0 -Maximum 2) -eq 1) {
                                $RandomLetters += $char.ToString().ToUpper()
                            } else {
                                $RandomLetters += $char.ToString().ToLower()
                            }
                        }
                        $RandomWord = $RandomLetters -join ""
                    }
                }
                $Words += $RandomWord
            }
            
            $ActualSeparator = $Separator
            if ($Separator -eq "None") {
                $ActualSeparator = ""
            }
            
            $Passphrase = $Words -join $ActualSeparator
            
            if (-not $ExcludeNumbers) {
                $RandomNumber = Get-Random -Minimum 0 -Maximum 99
                $Passphrase += $RandomNumber
            }
               

            if ($PwnCheck) {
                $Pwned = Get-PwnedPassword $Passphrase | Select-Object -ExpandProperty SeenCount
                if ($Pwned -gt 0) {
                    Write-Host "Passphrase $Passphrase is pwned, generating a new one instead - Pwned count: $Pwned" -ForegroundColor Yellow
                    continue
                }
            }

            $Passphrases += $Passphrase
            $GeneratedPassphrases++
        }

        if ($OutputPath) {
            $Passphrases | Out-File $OutputPath -Append -Force
        }

        if ($CopyToClipboard) {
            $Passphrases | Set-Clipboard
        }

        Write-Output $Passphrases
    }

    end {

    }
}


