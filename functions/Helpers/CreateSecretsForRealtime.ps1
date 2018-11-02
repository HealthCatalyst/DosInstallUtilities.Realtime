<#
.SYNOPSIS
CreateSecretsForRealtime

.DESCRIPTION
CreateSecretsForRealtime

.INPUTS
CreateSecretsForRealtime - The name of CreateSecretsForRealtime

.OUTPUTS
None

.EXAMPLE
CreateSecretsForRealtime

.EXAMPLE
CreateSecretsForRealtime


#>
function CreateSecretsForRealtime() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $namespace
    )

    Write-Verbose 'CreateSecretsForRealtime: Starting'

    CreateNamespaceIfNotExists -namespace $namespace

    $secret = "certhostname"
    $value = $(ReadSecretValue -secretname "dnshostname" -namespace "default")
    SaveSecretValue -secretname "certhostname" -valueName "value" -value "$value" -namespace "$namespace"

    $secret = "certpassword"
    $value = $(ReadSecretPassword -secretname "$secret" -namespace "default")
    SaveSecretPassword -secretname "$secret" -value "$value" -namespace "$namespace"

    # AskForSecretValue -secretname $secret -namespace $namespace -prompt "Enter hostname for certificates"

    $secret = "mysqlrootpassword"
    GenerateSecretPassword -secretname "$secret" -namespace "$namespace"
    $secret = "mysqlpassword"
    GenerateSecretPassword -secretname "$secret" -namespace "$namespace"
    $secret = "rabbitmqmgmtuipassword"
    GenerateSecretPassword -secretname "$secret" -namespace "$namespace"

    Write-Verbose 'CreateSecretsForRealtime: Done'
}

Export-ModuleMember -Function 'CreateSecretsForRealtime'