# ItemLinksManagement

```powershell
Import-Module .\src\ItemLinksManagement\ItemLinksManagement.psm1 -Force

# Add symbolic link
Add-Link -Path $path -ItemType SymbolicLink -Value $value

# Add junction
Add-Link -Path $path -ItemType Junction -Value $value

```

## Tips

- You can use the `-Force` flag to force override existing links.
- You can use the `-Verbose` for verbose output.
