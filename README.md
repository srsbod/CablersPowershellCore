# CablersPowershellCore

CablersPowershellCore is a PowerShell module designed to provide a collection of utilities for managing and automating tasks across devices. It includes functions for managing audio, disk space, installed software, and more.

---

## Table of Contents

- [CablersPowershellCore](#cablerspowershellcore)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
    - [Manual Installation](#manual-installation)
  - [Functions Overview](#functions-overview)
    - [Compare-Files](#compare-files)
    - [Compress-7z](#compress-7z)
    - [Get-AudioVolume](#get-audiovolume)
    - [Set-AudioVolume](#set-audiovolume)
    - [Get-DiskSpace](#get-diskspace)
    - [Get-InstalledSoftware](#get-installedsoftware)
    - [New-Credential](#new-credential)
    - [Test-EmptyFolder](#test-emptyfolder)
    - [Uninstall-Software](#uninstall-software)
    - [Get-InternalIP](#get-internalip)
    - [Get-IPAddressLocation](#get-ipaddresslocation)
    - [Get-LastBootTime](#get-lastboottime)
    - [Get-PublicIP](#get-publicip)
    - [Get-Uptime](#get-uptime)
    - [Remove-EmptyFolders](#remove-emptyfolders)
    - [New-Password](#new-password)
    - [Convert-PrefixToSubnetMask](#convert-prefixtosubnetmask)

---

## Prerequisites

1. **PowerShell Version**: This module requires PowerShell 5.1 or later.
2. **Code Signing Certificate**: The CablersPowershell code signing `.cer` file must be installed on the system to validate the module's authenticity.
   - To install the certificate:
     1. Double-click the `.cer` file.
     2. Follow the prompts to install it into the "Trusted Root Certification Authorities" store.

3. **Required Modules**:
   - `PwnedPassCheck` (Install via PowerShell Gallery):

     ```powershell
     Install-Module -Name PwnedPassCheck -Scope CurrentUser
     ```

---

## Installation

### Manual Installation

1. Download the module files and place them in a directory named `CablersPowershellCore` under one of the following paths:
   - For all users: `C:\Program Files\WindowsPowerShell\Modules`
   - For the current user: `C:\Users\<YourUsername>\Documents\WindowsPowerShell\Modules`

2. Ensure the `.cer` file for code signing is installed as described in the prerequisites.

3. Import the module into your session:

   ```powershell
   Import-Module -Name CablersPowershellCore
   ```

---

## Functions Overview

### Compare-Files

**Description**: Compares two files and determines if they are identical.

**Parameters**:

- `Path1` (String, Mandatory, Position: 0): The path to the first file.
- `Path2` (String, Mandatory, Position: 1): The path to the second file.

**Outputs**: Boolean (`$true` if files are identical, `$false` otherwise).

---

### Compress-7z

**Description**: Compresses files or folders into a `.7z` archive.

**Parameters**:

- `SourcePath` (String, Mandatory, Position: 0): Path to the file or folder to compress.
- `DeleteOriginal` (Switch, Optional): Deletes the original file/folder after compression.

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

- `Volume` (Integer, Mandatory, Position: 0): Volume level (0-100).
- `Mute` (Switch, Optional): Mutes the audio.

**Outputs**: None.

---

### Get-DiskSpace

**Description**: Retrieves disk space information for specified drives.

**Parameters**:

- `DriveLetter` (String[], Optional, Position: 0): Drive letters to query. Defaults to all drives.

**Outputs**: Custom object with properties for drive, used space, free space, etc.

---

### Get-InstalledSoftware

**Description**: Retrieves a list of installed software on the system.

**Parameters**:

- `SoftwareName` (String, Optional, Position: 0): Filters results by software name.

**Outputs**: Custom object with properties for name, version, install date, etc.

---

### New-Credential

**Description**: Creates a new PSCredential object.

**Parameters**:

- `Username` (String, Mandatory, Position: 0): The username for the credential.
- `Password` (String, Mandatory, Position: 1): The password for the credential.

**Outputs**: PSCredential object.

---

### Test-EmptyFolder

**Description**: Checks if a folder is empty.

**Parameters**:

- `Path` (String, Mandatory, Position: 0): Path to the folder.

**Outputs**: Boolean (`$true` if the folder is empty, `$false` otherwise).

---

### Uninstall-Software

**Description**: Uninstalls specified software from the system.

**Parameters**:

- `SoftwareName` (String, Mandatory, Position: 0): Name of the software to uninstall.

**Outputs**: None.

---

### Get-InternalIP

**Description**: Retrieves the internal IP address of the system.

**Parameters**: None.

**Outputs**: String (Internal IP address).

---

### Get-IPAddressLocation

**Description**: Retrieves the geographical location of the system's public IP address.

**Parameters**: None.

**Outputs**: Custom object with properties for country, region, city, etc.

---

### Get-LastBootTime

**Description**: Retrieves the last boot time of the system.

**Parameters**: None.

**Outputs**: DateTime (Last boot time).

---

### Get-PublicIP

**Description**: Retrieves the public IP address of the system.

**Parameters**: None.

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

- `Path` (String, Mandatory, Position: 0): Path to the directory.

**Outputs**: None.

---

### New-Password

**Description**: Generates a new random password.

**Parameters**:

- `Length` (Integer, Optional, Position: 0): Length of the password. Defaults to 12.

**Outputs**: String (Generated password).

---

### Convert-PrefixToSubnetMask

**Description**: Converts a CIDR prefix to a subnet mask. e.g.

``` text
  24 -> 255.255.255.0
 ```

**Parameters**:

- `PrefixLength` (Integer, Mandatory, Position: 0): CIDR prefix to convert.

**Outputs**: String (Subnet mask in dotted-decimal notation).
