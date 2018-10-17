$module = Get-Module -Name "DosInstallUtilities.Realtime"
$module | Select-Object *

$params = @{
    'Author' = 'Health Catalyst'
    'CompanyName' = 'Health Catalyst'
    'Description' = 'Functions to create realtime menus'
    'NestedModules' = 'DosInstallUtilities.Realtime'
    'Path' = ".\DosInstallUtilities.Realtime.psd1"
}

New-ModuleManifest @params
