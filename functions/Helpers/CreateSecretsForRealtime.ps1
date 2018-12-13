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
    Set-StrictMode -Version latest
    # stop whenever there is an error
    $ErrorActionPreference = "Stop"

    CreateNamespaceIfNotExists -namespace $namespace

    [string] $secret = "certhostname"
    [string] $value = $(ReadSecretValue -secretname "dnshostname" -namespace "default")
    SaveSecretValue -secretname "certhostname" -valueName "value" -value "$value" -namespace "$namespace"

    [string] $secret = "certpassword"
    $value = $(ReadSecretPassword -secretname "$secret" -namespace "default")
    if ([string]::IsNullOrEmpty($value)) {
        GenerateSecretPassword -secretname "$secret" -namespace "$namespace"
    }
    else {
        SaveSecretPassword -secretname "$secret" -value "$value" -namespace "$namespace"
    }

    # AskForSecretValue -secretname $secret -namespace $namespace -prompt "Enter hostname for certificates"

    $secret = "mysqlrootpassword"
    GenerateSecretPassword -secretname "$secret" -namespace "$namespace"
    $secret = "mysqlpassword"
    GenerateSecretPassword -secretname "$secret" -namespace "$namespace"
    $secret = "rabbitmqmgmtuipassword"
    GenerateSecretPassword -secretname "$secret" -namespace "$namespace"

    Write-Verbose "Copying ssl certificate secrets from kube-system to $namespace"
    [string] $secretName = "fabric-ca-cert"
    kubectl get secret $secretName --namespace=kube-system --export -o yaml | kubectl apply --namespace="$namespace" -f -
    [string] $secretName = "fabric-ssl-cert"
    kubectl get secret $secretName --namespace=kube-system --export -o yaml | kubectl apply --namespace="$namespace" -f -
    [string] $secretName = "fabric-client-cert"
    kubectl get secret $secretName --namespace=kube-system --export -o yaml | kubectl apply --namespace="$namespace" -f -
    [string] $secretName = "fabric-ssl-download-cert"
    kubectl get secret $secretName --namespace=kube-system --export -o yaml | kubectl apply --namespace="$namespace" -f -

    Write-Verbose 'CreateSecretsForRealtime: Done'
}

Export-ModuleMember -Function 'CreateSecretsForRealtime'