# CablersPowershellCore

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC_BY--NC--SA_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

CablersPowershellCore is a PowerShell module designed to provide a collection of utilities for managing and automating tasks across devices. It includes functions for managing audio, disk space, installed software, and more.

---

- [CablersPowershellCore](#cablerspowershellcore)
  - [Prerequisites](#prerequisites)
  - [Execution Policy \& Code Signing](#execution-policy--code-signing)
  - [Installation](#installation)
    - [Install from PowerShell Gallery (Recommended)](#install-from-powershell-gallery-recommended)
    - [Manual Installation](#manual-installation)
  - [Functions Overview](#functions-overview)
    - [Compare-Files](#compare-files)
    - [Compress-7z](#compress-7z)
    - [Convert-PrefixToSubnetMask](#convert-prefixtosubnetmask)
    - [Convert-StringToURI](#convert-stringtouri)
    - [Get-AudioVolume](#get-audiovolume)
    - [Get-DiskSpace](#get-diskspace)
    - [Get-InstalledSoftware](#get-installedsoftware)
    - [Get-InternalIP](#get-internalip)
    - [Get-IPAddressLocation](#get-ipaddresslocation)
    - [Get-LastBootTime](#get-lastboottime)
    - [Get-LongestCommonPrefix](#get-longestcommonprefix)
    - [Get-PublicIP](#get-publicip)
    - [Get-Uptime](#get-uptime)
    - [New-Credential](#new-credential)
    - [New-Password](#new-password)
    - [Remove-EmptyFolders](#remove-emptyfolders)
    - [Set-AudioVolume](#set-audiovolume)
    - [Set-Owner](#set-owner)
    - [Split-String](#split-string)
    - [Test-EmptyFolder](#test-emptyfolder)
    - [Test-IsAdmin](#test-isadmin)
    - [Uninstall-Software](#uninstall-software)

---

## Prerequisites

1. **PowerShell Version**: This module requires PowerShell 5.1 or later.
2. **Required Modules**:
   - `PwnedPassCheck` (Install via PowerShell Gallery):

     ```powershell
     Install-Module -Name PwnedPassCheck -Scope CurrentUser
     ```

---

## Execution Policy & Code Signing

- **PowerShell Gallery installation**: When installing from the PowerShell Gallery, the module is automatically trusted through the gallery's verification process.
- **Manual installation**: If you download the module manually, run `Get-ChildItem -Recurse *.ps1 | Unblock-File` in the module directory to mark files as safe.
- **Temporarily relax policy**: Use `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned` in an elevated session when testing on freshly provisioned hosts, then close the session to restore the previous policy.

This module sets `RequireLicenseAcceptance = $true` in the manifest. Installation via PowerShellGet prompts users to review and accept the license (see [License](#license)).

## Installation

### Install from PowerShell Gallery (Recommended)

The module is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/CablersPowershellCore). Install it with:

- All Users (requires admin, allows use by System)

  ```powershell
  Install-Module -Name CablersPowershellCore -Scope AllUsers -AllowClobber
  ```

- Current User

  ```powershell
  Install-Module -Name CablersPowershellCore -Scope CurrentUser -AllowClobber
  ```

After installation, import the module:

```powershell
Import-Module -Name CablersPowershellCore
```

Note: Allow Clobber is required in Powershell Core due to the inclusion of a few commands that exist in Core but not Windows Powershell. This is currently only `Get-Uptime` which behaves exactly the same as the one built into Powershell Core.

### Manual Installation

1. Download the module files and place them in a directory named `CablersPowershellCore` under one of the following paths:
   - For all users: `C:\Program Files\WindowsPowerShell\Modules`
   - For the current user: `C:\Users\<YourUsername>\Documents\WindowsPowerShell\Modules`

2. Import the module into your session:

   ```powershell
   Import-Module -Name CablersPowershellCore
   ```

---

## Functions Overview

### Compare-Files

**Description**: Compares two files and determines if they are identical.

**Parameters**:

| Name           | Type   | Mandatory | Position | Description                 | Default Value |
| -------------- | ------ | --------- | -------- | --------------------------- | ------------- |
| SourceFile     | String | Yes       | 0        | The path to the first file  |               |
| ComparisonFile | String | Yes       | 1        | The path to the second file |               |

**Outputs**: Object with the following structure:

| Property       | Type    | Description                                  |
| -------------- | ------- | -------------------------------------------- |
| FilesMatch     | Boolean | True if files are identical, False otherwise |
| SourceFile     | String  | Path to the source file                      |
| ComparisonFile | String  | Path to the comparison file                  |

---

### Compress-7z

**Description**: Compresses files or folders into a `.7z` archive.

**Parameters**:

| Name            | Type   | Mandatory | Position | Description                                        | Default Value |
| --------------- | ------ | --------- | -------- | -------------------------------------------------- | ------------- |
| SourcePath      | String | Yes       | 0        | Path to the file or folder to compress             |               |
| DestinationPath | String | Yes       | 1        | Path to save the compressed file                   |               |
| DeleteOriginal  | Switch | No        | Named    | Deletes the original file/folder after compression | False         |

**Outputs**: None.

---

### Get-AudioVolume

**Description**: Retrieves the current audio volume level.

**Parameters**: None.

**Outputs**: Integer (Volume level as a percentage).

---

### Set-AudioVolume

**Description**: Sets the audio volume or mutes/unmutes the audio.

**Parameters**:

| Name   | Type    | Mandatory | Position | Description          | Default Value |
| ------ | ------- | --------- | -------- | -------------------- | ------------- |
| Volume | Integer | Yes       | 0        | Volume level (0-100) |               |
| Mute   | Switch  | No        | Named    | Mutes the audio      | False         |

**Outputs**: None.

---

### Get-DiskSpace

**Description**: Retrieves disk space information for specified drives.

**Parameters**:

| Name        | Type      | Mandatory | Position | Description                 | Default Value |
| ----------- | --------- | --------- | -------- | --------------------------- | ------------- |
| DriveLetter | String[ ] | No        | 0        | Drive letters to query      | All drives    |
| Simple      | Switch    | No        | Named    | Returns a simplified output | False         |

**Outputs**: Custom object with the following structure:

| Property    | Type    | Description                          |
| ----------- | ------- | ------------------------------------ |
| Drive       | String  | Drive letter with colon (e.g., "C:") |
| Label       | String  | Volume label                         |
| SizeGB      | Decimal | Total size in GB                     |
| FreeGB      | Decimal | Free space in GB                     |
| UsedGB      | Decimal | Used space in GB                     |
| PercentUsed | Decimal | Percentage of used space             |
| PercentFree | Decimal | Percentage of free space             |

---

### Get-InstalledSoftware

**Description**: Retrieves a list of installed software on the system.

**Parameters**:

| Name         | Type   | Mandatory | Position | Description                                    | Default Value |
| ------------ | ------ | --------- | -------- | ---------------------------------------------- | ------------- |
| SoftwareName | String | No        | 0        | Filters results by software name (using regex) |               |

**Outputs**: Custom object with the following structure:

| Property             | Type     | Description                        |
| -------------------- | -------- | ---------------------------------- |
| Name                 | String   | Name of the installed software     |
| Version              | String   | Version number                     |
| Publisher            | String   | Software publisher                 |
| InstallDate          | DateTime | Date software was installed        |
| UninstallString      | String   | Command to uninstall the software  |
| QuietUninstallString | String   | Command for silent uninstallation  |
| GUID                 | String   | Unique identifier for the software |

---

### New-Credential

**Description**: Creates a new PSCredential object.

**Parameters**:

| Name     | Type   | Mandatory | Position | Description                     | Default Value |
| -------- | ------ | --------- | -------- | ------------------------------- | ------------- |
| Username | String | Yes       | 0        | The username for the credential |               |
| Password | String | Yes       | 1        | The password for the credential |               |

**Outputs**: PSCredential object.

---

### Test-EmptyFolder

**Description**: Checks if a folder is empty.

**Parameters**:

| Name | Type   | Mandatory | Position | Description        | Default Value |
| ---- | ------ | --------- | -------- | ------------------ | ------------- |
| Path | String | Yes       | 0        | Path to the folder |               |

**Outputs**: Boolean (`$true` if the folder is empty, `$false` otherwise).

---

### Uninstall-Software

**Description**: Uninstalls specified software from the system.

**Parameters**:

| Name         | Type   | Mandatory | Position | Description                       | Default Value |
| ------------ | ------ | --------- | -------- | --------------------------------- | ------------- |
| SoftwareName | String | Yes       | 0        | Name of the software to uninstall |               |

**Outputs**: None.

---

### Get-InternalIP

**Description**: Retrieves the internal IP address of the system.

**Parameters**: None.

**Outputs**: PSCustomObject

| Property        | Type     | Description                                           |
| --------------- | -------- | ----------------------------------------------------- |
| AdapterName     | String   | Name of the network adapter                           |
| Description     | String   | Description of the network adapter                    |
| Status          | String   | Status of the network adapter (e.g., "Up")            |
| IPv4Address     | String   | Internal IP address (only if status is "Up")          |
| SubnetMask      | String   | Subnet mask in CIDR notation (Only if status is "Up") |
| Gateway         | String   | Default gateway (Only if status is "Up")              |
| DnsServers      | String[] | DNS server addresses (Only if status is "Up")         |
| PrefixLength    | Int      | CIDR prefix length (Only if status is "Up")           |
| IPConfiguration | String   | IP configuration type (Only if status is "Up")        |

---

### Get-IPAddressLocation

**Description**: Retrieves the geographical location of a given public IP address.

**Parameters**:

| Name      | Type     | Mandatory | Value from Pipeline | Position | Description                | Default Value       |
| --------- | -------- | --------- | ------------------- | -------- | -------------------------- | ------------------- |
| IPAddress | [String] | No        | Yes                 | 0        | Public IP address to query | Public IPs to check |

**Outputs**: [PSCustomObject]

| Property    | Type   | Description               |
| ----------- | ------ | ------------------------- |
| IPAddress   | String | Public IP address         |
| Country     | String | Country name              |
| CountryCode | String | Country code              |
| ISP         | String | Internet Service Provider |

---

### Get-LastBootTime

**Description**: Retrieves the last boot time of the system.

**Parameters**: None.

**Outputs**: DateTime (Last boot time).

---

### Get-PublicIP

**Description**: Retrieves the public IP address of the system.

**Parameters**:

| Name            | Type   | Mandatory | Position | Description                               | Default Value |
| --------------- | ------ | --------- | -------- | ----------------------------------------- | ------------- |
| CopyToClipboard | Switch | No        | Named    | Copies the public IP address to clipboard | False         |

**Outputs**: String (Public IP address).

---

### Get-Uptime

**Description**: Retrieves the system uptime.

**Parameters**: None.

**Outputs**: TimeSpan (Duration since the last boot).

---

### Remove-EmptyFolders

**Description**: Removes empty folders from a specified directory.

**Parameters**:

| Name | Type   | Mandatory | Position | Description           | Default Value |
| ---- | ------ | --------- | -------- | --------------------- | ------------- |
| Path | String | Yes       | 0        | Path to the directory |               |

**Outputs**: [String] (List of removed empty folders).

---

### New-Password

**Description**: Generates a new random password.

**Parameters**:

| Name              | Type   | Mandatory          | Position | Description                                                | Default Value |
| ----------------- | ------ | ------------------ | -------- | ---------------------------------------------------------- | ------------- |
| Simple            | Switch | Yes (ParameterSet) | Named    | Generates a simple password (lowercase and numbers)        |               |
| Strong            | Switch | Yes (ParameterSet) | Named    | Generates a strong password (mixed case, numbers, symbols) |               |
| Random            | Switch | Yes (ParameterSet) | Named    | Generates a random password with customizable options      |               |
| Length            | Int    | No                 | Named    | Length of the password when using -Random                  | 12            |
| NoSymbols         | Switch | No                 | Named    | Excludes special characters from random passwords          | False         |
| PwnCheck          | Switch | No                 | Named    | Checks if the password has been exposed in data breaches   | False         |
| NumberOfPasswords | Int    | No                 | Named    | Number of passwords to generate                            | 1             |
| OutputPath        | String | No                 | Named    | Path to save passwords to a file                           |               |
| CopyToClipboard   | Switch | No                 | Named    | Copies the password to clipboard                           | False         |
| SleepTime         | Int    | No                 | Named    | Delay between API calls in milliseconds                    | 100           |

**Outputs**: String or String[] (Generated password(s)).

---

### Convert-PrefixToSubnetMask

**Description**: Converts a CIDR prefix to a subnet mask. e.g.

``` text
  24 -> 255.255.255.0
 ```

**Parameters**:

| Name         | Type | Mandatory | Position | Description                   | Default Value |
| ------------ | ---- | --------- | -------- | ----------------------------- | ------------- |
| PrefixLength | Int  | Yes       | 0        | CIDR prefix to convert (0-32) |               |

**Outputs**: String (Subnet mask in dotted-decimal notation).

---

### Convert-StringToURI

**Description**: Converts a string to a URI-encoded (URL-encoded) format using `EscapeDataString`. Useful for encoding query parameters or path components for URLs.

**Parameters**:

| Name        | Type   | Mandatory | Position | Description                       | Default Value |
| ----------- | ------ | --------- | -------- | --------------------------------- | ------------- |
| inputString | String | Yes       | 0        | The string to encode for URI use  |               |

**Aliases**: `URL`

**Outputs**: String (URI-encoded string).

---

### Get-LongestCommonPrefix

**Description**: Finds the longest common prefix string amongst an array of strings. Useful for comparing file paths or similar strings.

**Parameters**:

| Name    | Type     | Mandatory | Position | Description                                     | Default Value |
| ------- | -------- | --------- | -------- | ----------------------------------------------- | ------------- |
| Strings | String[] | Yes       | 0        | An array of strings to find common prefix among |               |

**Outputs**: String (Longest common prefix).

**Example**:

```powershell
Get-LongestCommonPrefix -Strings @("flower", "flow", "flight")
# Output: "fl"
```

---

### Set-Owner

**Description**: Sets the owner of a file or folder. Requires administrative privileges.

**Parameters**:

| Name  | Type   | Mandatory | Position | Description                                        | Default Value          |
| ----- | ------ | --------- | -------- | -------------------------------------------------- | ---------------------- |
| Path  | String | Yes       | 0        | Path to the file or folder                         |                        |
| Owner | String | No        | 1        | Owner to set (in format DOMAIN\User or BUILTIN\Group) | BUILTIN\Administrators |

**Outputs**: None.

---

### Split-String

**Description**: Splits a string based on a specified substring, returning either the portion before or after the split point. Optionally returns both parts.

**Parameters**:

| Name        | Type   | Mandatory | Position | Parameter Set | Description                                     | Default Value |
| ----------- | ------ | --------- | -------- | ------------- | ----------------------------------------------- | ------------- |
| InputString | String | Yes       | 0        | Both          | The string to split                             |               |
| SplitBefore | String | Yes       | Named    | Before        | Returns everything up to (not including) this substring |               |
| SplitAfter  | String | Yes       | 1        | After         | Returns everything up to and including this substring |               |
| ReturnBoth  | Switch | No        | Named    | Both          | Returns both parts of the split                 | False         |

**Outputs**: String or String[] (Split portion(s) of the input string).

---

### Test-IsAdmin

**Description**: Tests if the current PowerShell session is running with administrative privileges. Works on both Windows PowerShell and PowerShell Core.

**Parameters**: None.

**Outputs**: Boolean (`$true` if running as administrator, `$false` otherwise).

---

## Release Checklist

- [ ] Run the integration tests locally or via `Invoke-Pester`.
- [ ] Update `CablersPowershellCore.psd1` with the new `ModuleVersion` and release notes.
- [ ] Confirm `README.md` reflects any new parameters or dependencies.
- [ ] Verify `.github/workflows/BuildAndRelease.yaml` secrets (`PS_GALLERY_API_KEY`) are present before tagging.
- [ ] Create a signed or unsigned package as required and push tags to trigger automation.

---

## License

This project is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/). Any installation from the PowerShell Gallery or manual distribution requires explicit acceptance of the license terms.
