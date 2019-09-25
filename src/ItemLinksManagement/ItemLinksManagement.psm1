$PSDefaultParameterValues.Clear()
Set-StrictMode -Version Latest

##################
# Module globals #
##################

# Module constants
$script:MODULE = @{}
$script:MODULE['BASE_DIR'] = $PSScriptRoot
$script:MODULE['PUBLIC_DIR'] = Join-Path $script:MODULE['BASE_DIR'] 'Public'          # Module public functions

# Load vendor, Public, Private, classes, helpers
Get-ChildItem "$( $script:MODULE['PUBLIC_DIR'] )/*.ps1"  | % { . $_.FullName }

# Export Public functions
Export-ModuleMember -Function @( Get-ChildItem "$( $script:MODULE['PUBLIC_DIR'] )/*.ps1" | Select-Object -ExpandProperty BaseName )
