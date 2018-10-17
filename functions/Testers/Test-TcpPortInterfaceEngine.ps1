<#
.SYNOPSIS
Test-TcpPortInterfaceEngine

.DESCRIPTION
Test-TcpPortInterfaceEngine

.INPUTS
Test-TcpPortInterfaceEngine - The name of Test-TcpPortInterfaceEngine

.OUTPUTS
None

.EXAMPLE
Test-TcpPortInterfaceEngine

.EXAMPLE
Test-TcpPortInterfaceEngine


#>
function Test-TcpPortInterfaceEngine() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InterfaceEngineHost
    )

    Write-Verbose 'Test-TcpPortInterfaceEngine: Starting'

    [int] $port = 6661
    [bool] $result = $(Test-NetConnection -ComputerName "$InterfaceEngineHost" -Port $port -InformationLevel Quiet)
    if ($result) {
        Write-Host "TCP ping succeeded to $InterfaceEngineHost on port $port"
    }
    else {
        Write-Host "TCP ping FAILED to $InterfaceEngineHost on port $port.  Running diagnostics"
        Test-NetConnection -ComputerName "$InterfaceEngineHost" -Port $port -InformationLevel Detailed
    }

    Write-Verbose 'Test-TcpPortInterfaceEngine: Done'

}

Export-ModuleMember -Function 'Test-TcpPortInterfaceEngine'