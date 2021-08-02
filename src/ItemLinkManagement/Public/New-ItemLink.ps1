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
            $item = Get-Item -Path $_path -Force -ErrorAction SilentlyContinue
            if ($item) {
                if (!$item.LinkType) {
                    throw "Existing item '$_path' is not a HardLink, Junction, or SymbolicLink."
                }
                if (!$Force) {
                    if (($item.LinkType -eq $ItemType) -and ($item.Target -eq $_value)) {
                        "Matching item '$_path' already exists. Skipping" | Write-Verbose
                        return
                    }
                }
                # New-Item with -Force cannot override an existing Junction, hence the need to remove the existing Link: Junction, SymbolicLink, or HardLink
                if ($ItemType -eq 'Junction') {
                    if ($PSVersionTable.PSVersion.Major -le 5 -and $item.Attributes -match 'ReparsePoint') {
                        $item.Delete() # Powershell 5 requires a special way to remove a SymbolicLink, see: https://stackoverflow.com/a/63172492
                    }else {
                        $item | Remove-Item -Force
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
