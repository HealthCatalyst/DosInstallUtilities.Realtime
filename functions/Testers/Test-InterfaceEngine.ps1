<#
.SYNOPSIS
Test-InterfaceEngine

.DESCRIPTION
Test-InterfaceEngine

.INPUTS
Test-InterfaceEngine - The name of Test-InterfaceEngine

.OUTPUTS
None

.EXAMPLE
Test-InterfaceEngine

.EXAMPLE
Test-InterfaceEngine


#>
function Test-InterfaceEngine() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InterfaceEngineHost
    )

    Write-Verbose 'Test-InterfaceEngine: Starting'

    [int] $port = 6661
    [bool] $result = $(Test-NetConnection -ComputerName "$InterfaceEngineHost" -Port $port -InformationLevel Quiet)
    if ($result) {
        Write-Host "TCP ping succeeded to $InterfaceEngineHost on port $port"
    }
    else {
        Write-Host "TCP ping FAILED to $InterfaceEngineHost on port $port.  Running diagnostics"
        Test-NetConnection -ComputerName "$InterfaceEngineHost" -Port $port -InformationLevel Detailed
    }

    Write-Verbose 'Test-InterfaceEngine: Done'

}

Export-ModuleMember -Function 'Test-InterfaceEngine'