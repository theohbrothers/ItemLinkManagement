function Add-Link {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$path
        ,
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateSet("SymbolicLink", "Junction")]
        [string]$ItemType
        ,
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$value
        ,
        [Parameter(Mandatory=$false)]
        [switch]$Force
    )
    begin {
        $path = $Path.Trim()
        $value = $Value.Trim()
        if ($env:OS -eq 'Windows_NT') {
            $path = $path -replace "/","\"
            $value = $value -replace "/","\"
        }
    }process {
        try {
            "ItemType: '$($ItemType)', Path: '$($path)', Value: '$($value)'" | Write-Verbose
            $item = Get-Item -Path $path -ErrorAction SilentlyContinue
            if ($item) {
                if (!$item.LinkType) {
                    throw "Existing item '$path' is not a SymbolicLink or Junction."
                }
                if (($item.LinkType -eq $ItemType) -and ($item.Target -eq $value)) {
                    "Matching item '$path' already exists. Skipping" | Write-Verbose
                    return
                }
                if ($item.LinkType -ne $ItemType) {            # New-Item -Force does not work for junctions, hence the need to remove the existing item
                    "Removing existing junction item '$path'" | Write-Verbose
                    $item.Delete()                                                  # Remove-Item -Force and -Confirm:$false do not suppress confirmation for removal if items exists within symlink or junction target
                }
            }
            "Creating item '$path'" | Write-Verbose
            New-Item -Path $path -ItemType $ItemType -Value $value -Force:$Force
        }catch {
            Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
        }
    }
}
