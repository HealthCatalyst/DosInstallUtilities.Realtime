<#
.SYNOPSIS
ShowUrlsAndPasswordsForRealtime

.DESCRIPTION
ShowUrlsAndPasswordsForRealtime

.INPUTS
ShowUrlsAndPasswordsForRealtime - The name of ShowUrlsAndPasswordsForRealtime

.OUTPUTS
None

.EXAMPLE
ShowUrlsAndPasswordsForRealtime

.EXAMPLE
ShowUrlsAndPasswordsForRealtime


#>
function ShowUrlsAndPasswordsForRealtime()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $namespace
    )

    Write-Verbose 'ShowUrlsAndPasswordsForRealtime: Starting'
    Set-StrictMode -Version latest
    $ErrorActionPreference = 'Stop'

    $certhostname = $(ReadSecretValue certhostname $namespace)
    Write-Host "Send HL7 to Mirth: server=${certhostname} port=6661"
    Write-Host "Rabbitmq Queue: server=${certhostname} port=5671"
    $rabbitmqpassword = $(ReadSecretPassword rabbitmqmgmtuipassword $namespace)
    Write-Host "RabbitMq Mgmt UI is at: http://${certhostname}/rabbitmq/ user: admin password: $rabbitmqpassword"
    Write-Host "Mirth Mgmt UI is at: http://${certhostname}/mirth/ user: admin password:admin"

    $secrets = $(kubectl get secrets -n $namespace -o jsonpath="{.items[?(@.type=='Opaque')].metadata.name}")
    Write-Host "All secrets in $namespace : $secrets"
    WriteSecretPasswordToOutput -namespace $namespace -secretname "mysqlrootpassword"
    WriteSecretPasswordToOutput -namespace $namespace -secretname "mysqlpassword"
    WriteSecretValueToOutput  -namespace $namespace -secretname "certhostname"
    WriteSecretPasswordToOutput -namespace $namespace -secretname "certpassword"
    WriteSecretPasswordToOutput -namespace $namespace -secretname "rabbitmqmgmtuipassword"

    Write-Verbose 'ShowUrlsAndPasswordsForRealtime: Done'
}

Export-ModuleMember -Function 'ShowUrlsAndPasswordsForRealtime'