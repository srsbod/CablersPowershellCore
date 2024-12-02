# Find all duplicate files in a folder and subfolders
# Duplicates will be displayed in a grid view and can be selected for archiving or deleting if required
# Selected files will be moved to a specified archive folder or deleted depending on params
# If not archiving, returns a list of duplicate files

#TODO Extensive testing
#TODO Add support for -WhatIf
#TODO Add support for -Verbose
#TODO Add support for -Debug?
#TODO Add comment based help

function Get-DuplicateFiles {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$FolderPath,
        [Parameter(ParameterSetName = "Archive")]
        [string]$ArchivePath,
        [Parameter(ParameterSetName = "Delete")]
        [switch]$Delete
    )

    begin {
        Write-Debug "Begin"
        #Validate the folder path
        if (-not (Test-Path -Path $FolderPath -ErrorAction SilentlyContinue)) {
            Throw "Folder at path $FolderPath does not exist"
        }

        #Validate the archive drive
        if ($PSCmdlet.ParameterSetName -eq "Archive") {
            if (-not (Test-Path -Path $ArchivePath -ErrorAction SilentlyContinue)) {
                Throw "Archive path at path $ArchivePath does not exist"
            }
        }
    }

    process {
        Write-Debug "Process"

        Write-Debug "Getting files in $FolderPath"
        $Files = Get-ChildItem -Path $FolderPath -File -Recurse

        # Group files by hash
        $GroupedFiles = $Files | Group-Object -Property { Get-FileHash $_.FullName | Select-Object -ExpandProperty Hash }

        Write-Debug "Filtering out Non-duplicate files"
        $DuplicateFiles = $GroupedFiles | Where-Object { $_.Count -gt 1 }

        # Create an empty array to store the selected files
        $DuplicateFilesArray = @()

        # Iterate through the duplicate files and add them to the array with their hash
        $DuplicateFiles | ForEach-Object {
            $Hash = $_.Name
            $DuplicateFilesArray += $_.Group | Select-Object FullName, @{Name = "Hash"; Expression = { $Hash } }
        }

        If ($DuplicateFilesArray.Count -eq 0) {
            Write-Output "No duplicate files found in $FolderPath"
            return $null
        }

        # If we are not archiving or deleting, return the list of duplicate files
        If ($PSCmdlet.ParameterSetName -eq "Default") {
            return $DuplicateFilesArray
        }

        # Display the selected files in a grid view and allow the user to select files for archiving or deleting
        $SelectedFiles = $DuplicateFilesArray | Select-Object FullName, Hash | Out-GridView -PassThru

        # If no files are selected, return
        If (-not $SelectedFiles) {
            Write-Output "No files selected"
            return $null
        }

        # Archive selected files
        If ($PSCmdlet.ParameterSetName -eq "Archive") {
            Archive-File -SourcePath $SelectedFiles.FullName -ArchivePath $ArchivePath
        }

        # Delete selected files
        If ($PSCmdlet.ParameterSetName -eq "Delete" -and $Delete) {

            $TotalFiles = $SelectedFiles.Count
            $Counter = 0

            Write-Debug "Beginning delete process"
            Foreach ($File in $SelectedFiles) {

                $Counter++
                Write-Progress -Activity "Archiving Files" -Status "Processing file $Counter of $TotalFiles" -PercentComplete (($Counter / $TotalFiles) * 100)

                Write-Debug "Deleting file: $($File.FullName)"
                Remove-Item -Path $File.FullName -Force
            }
        }
    }

    end {
        Write-Debug "End"
    }
}
