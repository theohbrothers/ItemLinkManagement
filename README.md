# ItemLinkManagement

[![badge-build-azuredevops-build-img][]][badge-build-azuredevops-build-src] [![badge-version-github-release-img][]][badge-version-github-release-src] [![badge-version-powershellgallery-releases-img][]][badge-version-powershellgallery-releases-src]

[badge-build-azuredevops-build-img]: https://img.shields.io/azure-devops/build/theohbrothers/ItemLinkManagement/9/master.svg?label=build&logo=azure-pipelines&style=flat-square
[badge-build-azuredevops-build-src]: https://dev.azure.com/theohbrothers/ItemLinkManagement/_build?definitionId=9
[badge-version-github-release-img]: https://img.shields.io/github/v/release/theohbrothers/ItemLinkManagement?style=flat-square
[badge-version-github-release-src]: https://github.com/theohbrothers/ItemLinkManagement/releases
[badge-version-powershellgallery-releases-img]: https://img.shields.io/powershellgallery/v/ItemLinkManagement?logo=powershell&logoColor=white&label=PSGallery&labelColor=&style=flat-square
[badge-version-powershellgallery-releases-src]: https://www.powershellgallery.com/packages/ItemLinkManagement/

## Deprecation Notice

The module is merely a wrapper around PowerShell's built-in cmdlet `New-Item` to allow "overwriting" of existing junctions by removing existing ones before creation of replacement links regardless of PowerShell version. Everything else about link creation can already be achieved with `New-Item -Force`. As such, the module is now deprecated.

To create links without the module, first define links as spelt out [here](#links). Links can then be retrieved from definition files like so:

```powershell
# Via .ps1 link definition file
$links = . "/path/to/links.ps1"

# Via .ps1 link definition file(s) within directory
$links = Get-ChildItem -Path "/path/to/links/" -File | ? { $_.Extension -eq '.ps1' } | Sort-Object | % { . $_.FullName }
```

Once retrieved, links can easily be created via following snippet:

```powershell
# Create links
$links | % {
    try {
        "Path: '$($_.Path )', Value: '$($_.Value)', ItemType: '$($_.ItemType)'" | Write-Verbose
        $item = Get-Item -Path $_.Path -Force -ErrorAction SilentlyContinue
        # New-Item with -Force cannot override an existing Junction, hence the need to remove the existing Link: Junction, SymbolicLink, or HardLink
        if ($item -And $_.ItemType -eq 'Junction') {
            if ($PSVersionTable.PSVersion.Major -le 5) {
                $item.Delete() # Powershell 5 requires a special way to remove a SymbolicLink, see: https://stackoverflow.com/a/63172492
            }else {
                $item | Remove-Item -Force
            }
        }
        "Creating item '$($_.Path)'" | Write-Verbose
        New-Item -Path $_.Path -Value $_.Value -ItemType $_.ItemType -Force -Verbose
    }catch {
        $_ | Write-Error
    }
}
```

Alternatively, links can be retrieved and piped straight for creation without storing them in a variable:

```powershell
# Via .ps1 link definition file
. "/path/to/links.ps1" | % {
    try {
        ...

# Via .ps1 link definition file(s) within directory
Get-ChildItem -Path "/path/to/links/" -File | ? { $_.Extension -eq '.ps1' } | Sort-Object | % { . $_.FullName } | % {
    try {
        ...
```

## Introduction

A PowerShell module for managing hardlinks, junctions, and symbolic links.

## Requirements

* **Windows** with [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell), or ***nix** with [PowerShell Core](https://github.com/powershell/powershell#-powershell).

## Installation

First, ensure [`PSGallery`](https://www.powershellgallery.com/) is registered as a PowerShell repository:

```powershell
Register-PSRepository -Default -Verbose
```

To install the module:

```powershell
# Latest, for the current user
Install-Module -Name ItemLinkManagement -Repository PSGallery -Scope CurrentUser -Verbose

# Specific version, for the current user
Install-Module -Name ItemLinkManagement -Repository PSGallery -RequiredVersion x.x.x -Scope CurrentUser -Verbose

# Latest, for all users
Install-Module -Name ItemLinkManagement -Repository PSGallery -Scope AllUsers -Verbose
```

## Usage

### Links

To create links, first define the properties of each link in `.ps1` or `.json` file(s). Then feed the array of objects to `New-ItemLink` to create them non-interactively.

Sample definition files can be found [here](docs/samples/definitions/links).

### Functions

#### Parameters

```powershell
New-ItemLink [-Path] <string> [-Value] <string> [-ItemType] {HardLink | Junction | SymbolicLink} [-Force] [<CommonParameters>]
```

#### Examples

```powershell
# Hardlink
New-ItemLink -Path /path/of/link -Value /path/of/origin -ItemType Hardlink

# Junction
New-ItemLink -Path /path/of/link -Value /path/of/origin -ItemType Junction

# Symbolic link
New-ItemLink -Path /path/of/link -Value /path/of/origin -ItemType SymbolicLink

# Via definition objects
$links = . "/path/to/definition.ps1"
$links | % { New-ItemLink -Path $_.Path -ItemType $_.ItemType -Value $_.Value }

# Tips
## Specify `-Force` to overwrite existing links.
## Specify `-Verbose` for verbose output.
```

To list all available functions of the module:

```powershell
Get-Command -Module ItemLinkManagement
```

## Administration

### Versions

To list versions of the module on `PSGallery`:

```powershell
# Latest
Find-Module -Name ItemLinkManagement -Repository PSGallery -Verbose

# All versions
Find-Module -Name ItemLinkManagement -Repository PSGallery -AllVersions -Verbose
```

To update the module (**Existing versions are left intact**):

```powershell
# Latest
Update-Module -Name ItemLinkManagement -Verbose

# Specific version
Update-Module -Name ItemLinkManagement -RequiredVersion x.x.x -Verbose
```

To uninstall the module:

```powershell
# Latest
Uninstall-Module -Name ItemLinkManagement -Verbose

# All versions
Uninstall-Module -Name ItemLinkManagement -AllVersions -Verbose

# To uninstall all other versions other than x.x.x
Get-Module -Name ItemLinkManagement -ListAvailable | ? { $_.Version -ne 'x.x.x' } | % { Uninstall-Module -Name $_.Name -RequiredVersion $_.Version -Verbose }

# Tip: Simulate uninstalls with -WhatIf
```

### Repositories

To get all registered PowerShell repositories:

```powershell
Get-PSRepository -Verbose
```

To set the installation policy for the `PSGallery` repository:

```powershell
# PSGallery (trusted)
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose

# PSGallery (untrusted)
Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted -Verbose
```

### Development

To import / re-import the module:

```powershell
# Installed version
Import-Module -Name ItemLinkManagement -Force -Verbose

# Project version
Import-Module .\src\ItemLinkManagement\ItemLinkManagement.psm1 -Force -Verbose
```

To remove imported functions of the module:

```powershell
Remove-Module -Name ItemLinkManagement -Verbose
```

To list imported versions of the module:

```powershell
Get-Module -Name ItemLinkManagement
```

To list all installed versions of the module available for import:

```powershell
Get-Module -Name ItemLinkManagement -ListAvailable -Verbose
```
