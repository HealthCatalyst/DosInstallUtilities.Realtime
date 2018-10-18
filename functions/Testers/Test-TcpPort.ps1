<#
.SYNOPSIS
Test-TcpPort

.DESCRIPTION
Test-TcpPort

.INPUTS
Test-TcpPort - The name of Test-TcpPort

.OUTPUTS
None

.EXAMPLE
Test-TcpPort

.EXAMPLE
Test-TcpPort


#>
function Test-TcpPort() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InterfaceEngineHost
        ,
        [Parameter(Mandatory=$true)]
        [ValidateRange(0,10000)]
        [int]
        $port
    )

    Write-Verbose 'Test-TcpPort: Starting'

    [bool] $result = $(Test-NetConnection -ComputerName "$InterfaceEngineHost" -Port $port -InformationLevel Quiet)
    if ($result) {
        Write-Host "TCP ping succeeded to $InterfaceEngineHost on port $port"
    }
    else {
        Write-Host "TCP ping FAILED to $InterfaceEngineHost on port $port.  Running diagnostics"
        Test-NetConnection -ComputerName "$InterfaceEngineHost" -Port $port -InformationLevel Detailed
    }

    Write-Verbose 'Test-TcpPort: Done'

}

Export-ModuleMember -Function 'Test-TcpPort'