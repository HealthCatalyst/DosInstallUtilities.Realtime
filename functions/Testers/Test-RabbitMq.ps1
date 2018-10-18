<#
.SYNOPSIS
Test-RabbitMq

.DESCRIPTION
Test-RabbitMq

.INPUTS
Test-RabbitMq - The name of Test-RabbitMq

.OUTPUTS
None

.EXAMPLE
Test-RabbitMq

.EXAMPLE
Test-RabbitMq


#>
function Test-RabbitMq() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $RabbitMqHost
    )

    Write-Verbose 'Test-RabbitMq: Starting'

    #Define a default RabbitMQ server and get a credential to use
    # Set-RabbitMQConfig -ComputerName $RabbitMqHost
    # $CredRabbit = Get-Credential

    #Convenience - tab completion support for BaseUri
    Register-RabbitMQServer -BaseUri "http://${RabbitMqHost}:15672"

    #Set some common parameters we will always use:
    $Params = @{
        BaseUri = "http://${RabbitMqHost}:15672"
        # Credential = $CredRabbit
        # Ssl        = 'Tls12' #I'm using SSL... omit this if you aren't
    }

    Get-RabbitMQOverview @params

    Write-Verbose 'Test-RabbitMq: Done'

}

Export-ModuleMember -Function 'Test-RabbitMq'