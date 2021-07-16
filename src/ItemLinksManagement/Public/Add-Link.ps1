function Add-Link {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
        ,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("SymbolicLink", "Junction")]
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
        $_path = $Path.Trim()
        $_value = $Value.Trim()
        if ($env:OS -eq 'Windows_NT') {
            $_path = $_path -replace "/","\"
            $_value = $_value -replace "/","\"
        }
    }process {
        try {
            "ItemType: '$($ItemType)', Path: '$($_path)', Value: '$($_value)'" | Write-Verbose
            $item = Get-Item -Path $_path -ErrorAction SilentlyContinue
            if ($item) {
                if (!$item.LinkType) {
                    throw "Existing item '$_path' is not a SymbolicLink or Junction."
                }
                if (($item.LinkType -eq $ItemType) -and ($item.Target -eq $_value)) {
                    "Matching item '$_path' already exists. Skipping" | Write-Verbose
                    return
                }
                if ($ItemType -eq 'Junction') {
                    if ($item.LinkType -ne $ItemType) {                             # New-Item -Force does not work for junctions, hence the need to remove the existing item
                        "Itemtype specified as 'Junction'. Removing differing existing link '$Path'" | Write-Verbose
                        $item.Delete()                                              # Remove-Item -Force and -Confirm:$false do not suppress confirmation for removal if items exists within symlink or junction target
                    }
                }
            }
            "Creating item '$_path'" | Write-Verbose
            New-Item -Path $_path -ItemType $ItemType -Value $_value -Force:$Force
        }catch {
            Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
        }
    }
}
