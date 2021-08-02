function New-ItemLink {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
        ,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('HardLink', 'Junction', 'SymbolicLink')]
        [string]$ItemType
        ,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Value
        ,
        [Parameter(Mandatory=$false)]
        [switch]$Force
    )
    begin {
        $_errorActionPreference = $ErrorActionPreference
        $_path = $Path.Trim()
        $_value = $Value.Trim()
        if ($env:OS -eq 'Windows_NT') {
            $_path = $_path -replace "/","\"
            $_value = $_value -replace "/","\"
        }
    }process {
        try {
            $ErrorActionPreference = 'Stop'
            "ItemType: '$($ItemType)', Path: '$($_path)', Value: '$($_value)'" | Write-Verbose
            $item = Get-Item -Path $_path -ErrorAction SilentlyContinue
            if ($item) {
                if (!$item.LinkType) {
                    throw "Existing item '$_path' is not a HardLink, Junction, or SymbolicLink."
                }
                if (($item.LinkType -eq $ItemType) -and ($item.Target -eq $_value)) {
                    "Matching item '$_path' already exists. Skipping" | Write-Verbose
                    return
                }
                if ($ItemType -eq 'Junction') {
                    if ($item.LinkType -ne $ItemType) {                             # New-Item -Force does not work for junctions, hence the need to remove the existing item
                        "Itemtype specified as 'Junction'. Removing item '$($item.FullName)' of different item type '$($item.LinkType)'" | Write-Verbose
                        $item.Delete()                                              # Remove-Item -Force and -Confirm:$false do not suppress confirmation for removal if items exists within symlink or junction target
                    }
                }
            }
            "Creating item '$_path'" | Write-Verbose
            New-Item -Path $_path -ItemType $ItemType -Value $_value -Force:$Force
        }catch {
            Write-Error -ErrorRecord $_ -ErrorAction $_errorActionPreference
        }
    }
}
