# ItemLinkManagement

[![badge-build-azuredevops-build-img][]][badge-build-azuredevops-build-src] [![badge-version-github-release-img][]][badge-version-github-release-src] [![badge-version-powershellgallery-releases-img][]][badge-version-powershellgallery-releases-src]

[badge-build-azuredevops-build-img]: https://img.shields.io/azure-devops/build/theohbrothers/ItemLinkManagement/9/master.svg?label=build&logo=azure-pipelines&style=flat-square
[badge-build-azuredevops-build-src]: https://dev.azure.com/theohbrothers/ItemLinkManagement/_build?definitionId=9
[badge-version-github-release-img]: https://img.shields.io/github/v/release/theohbrothers/ItemLinkManagement?style=flat-square
[badge-version-github-release-src]: https://github.com/theohbrothers/ItemLinkManagement/releases
[badge-version-powershellgallery-releases-img]: https://img.shields.io/powershellgallery/v/ItemLinkManagement?logo=powershell&logoColor=white&label=PSGallery&labelColor=&style=flat-square
[badge-version-powershellgallery-releases-src]: https://www.powershellgallery.com/packages/ItemLinkManagement/

A PowerShell module for managing hardlinks, junctions, symbolic links.

The project is now [deprecated](#deprecation).

## Install

Open [`powershell`](https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/install/installing-windows-powershell?view=powershell-5.1) or [`pwsh`](https://github.com/powershell/powershell#-powershell) and type:

```powershell
Install-Module -Name Get-DuplicateItem -Repository PSGallery -Scope CurrentUser -Verbose
```

## Usage

```powershell
Import-Module ItemLinkManagement

# Hardlink
New-ItemLink -Path /path/of/link -Value /path/of/origin -ItemType Hardlink

# Junction
New-ItemLink -Path /path/of/link -Value /path/of/origin -ItemType Junction

# Symbolic link
New-ItemLink -Path /path/of/link -Value /path/of/origin -ItemType SymbolicLink
```

## Deprecation

This module is merely a wrapper around `New-Item`, covering only one special case which is overwriting of an existing `Junction` for Powershell v5. Everything else can already be done using `New-Item -Force`:

```powershell
# The only thing to remember is that in Powershell v5, remove an existing Junction before using New-Item, because New-Item -Force throws an error.
Remove-Item /path/to/link
New-Item -Path /path/to/link -Value /path/to/source -ItemType Junction

# -Force will overwrite existing links nicely in all other versions of Powershell
New-Item -Path /path/to/link -Value /path/to/source -ItemType <ItemType> -Force
```
