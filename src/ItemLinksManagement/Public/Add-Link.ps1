function Add-Link {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
        ,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemType
        ,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Value
        ,
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [switch]$Force
    )
    begin {
        $Path = $Path.Trim()
        $ItemType = $ItemType.Trim()
        $Value = $Value.Trim()
    }process {
        try {
            if ($ItemType -notmatch '^(symbolicLink|junction)$') {
                throw "The only valid item types are 'symbolicLink' or 'junction'."
            }
            "ItemType: '$($ItemType)', Path: '$($Path)', Value: '$($Value)'" | Write-Verbose
            $item = Get-Item -Path $Path -ErrorAction SilentlyContinue
            if ($item) {
                if (!$item.LinkType) {
                    throw "Item '$Path' is not a SymbolicLink or Junction."
                }
                if (($item.LinkType -eq $LinkType) -and ($item.Target -eq $Value)) {
                    "Matching item '$Path' already exists. Skipping" | Write-Verbose
                    return
                }
                if ($item.LinkType -eq 'Junction') {                                # New-Item -Force does not work for junctions, hence the need to remove the existing item
                    "Removing existing junction item '$Path'" | Write-Verbose
                    $item.Delete()                                                  # Remove-Item -Force and -Confirm:$false do not suppress confirmation for removal if items exists within symlink or junction target
                }
            }
            "Creating item '$Path'" | Write-Verbose
            New-Item -Path $Path -ItemType $ItemType -Value $Value -Force:$Force
        }catch {
            $_ | Write-Error
        }
    }
}
