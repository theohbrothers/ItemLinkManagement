# Add-Link

```powershell
Import-Module .\Add-Link.psm1 -Force

# Add symbolic link
Add-Link -Path $path -ItemType SymbolicLink -Value $value

# Add junction
Add-Link -Path $path -ItemType Junction -Value $value

```

## Tips

- You can use the `-Force` flag to force override existing links.
