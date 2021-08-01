# ItemLinkManagement

A powershell module for managing hardlinks, symlinks, and junctions.

```powershell
Import-Module .\src\ItemLinkManagement\ItemLinkManagement.psm1 -Force -Verbose

# Add symbolic link
New-ItemLink -Path $path -ItemType SymbolicLink -Value $value

# Add junction
New-ItemLink -Path $path -ItemType Junction -Value $value

```

## Tips

- You can use the `-Force` flag to force override existing links.
- You can use the `-Verbose` for verbose output.
