<#
.SYNOPSIS
CreateSecretsForStack

.DESCRIPTION
CreateSecretsForStack

.INPUTS
CreateSecretsForStack - The name of CreateSecretsForStack

.OUTPUTS
None

.EXAMPLE
CreateSecretsForStack

.EXAMPLE
CreateSecretsForStack


#>
function CreateSecretsForStack() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $namespace
    )

    Write-Verbose 'CreateSecretsForStack: Starting'

    CreateNamespaceIfNotExists -namespace $namespace

    $secret = "certhostname"
    # $value = $(ReadSecretValue -secretname "dnshostname" -namespace "default")
    # SaveSecretValue -secretname "certhostname" -valueName "value" -value "$value" -namespace "$namespace"

    AskForSecretValue -secretname $secret -namespace $namespace -prompt "Enter hostname for certificates"

    $secret = "mysqlrootpassword"
    GenerateSecretPassword -secretname "$secret" -namespace "$namespace"
    $secret = "mysqlpassword"
    GenerateSecretPassword -secretname "$secret" -namespace "$namespace"
    $secret = "certpassword"
    GenerateSecretPassword -secretname "$secret" -namespace "$namespace"
    $secret = "rabbitmqmgmtuipassword"
    GenerateSecretPassword -secretname "$secret" -namespace "$namespace"

    Write-Verbose 'CreateSecretsForStack: Done'
}

Export-ModuleMember -Function 'CreateSecretsForStack'