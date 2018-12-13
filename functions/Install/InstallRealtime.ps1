<#
.SYNOPSIS
InstallRealtime

.DESCRIPTION
InstallRealtime

.INPUTS
InstallRealtime - The name of InstallRealtime

.OUTPUTS
None

.EXAMPLE
InstallRealtime

.EXAMPLE
InstallRealtime


#>
function InstallRealtime() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $namespace
        ,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $package
        ,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $packageUrl
        ,
        [Parameter(Mandatory = $true)]
        [bool]
        $local
        ,
        [Parameter(Mandatory = $true)]
        [bool]
        $isAzure
    )

    Write-Verbose 'InstallRealtime: Starting'
    Set-StrictMode -Version latest
    $ErrorActionPreference = 'Stop'

    CreateSecretsForRealtime -namespace $namespace -Verbose

    if ($isAzure) {
        CreateAzureStorage -namespace $namespace
    }
    else {
        CreateOnPremStorage -namespace $namespace
    }

    Write-Output "Removing old deployment for $package"
    DeleteHelmPackage -package $package

    if ($namespace -ne "kube-system") {
        CleanOutNamespace -namespace $namespace
    }

    Write-Host "Installing product from $packageUrl into $namespace"

    if ($isAzure) {
        helm install $packageUrl `
            --name $package `
            --namespace $namespace `
            --debug
    }
    else {
        helm install $packageUrl `
            --name $package `
            --namespace $namespace `
            --set onprem=true `
            --debug
    }

    Write-Verbose "Listing packages"
    [string] $failedText = $(helm list --failed --output json)
    if (![string]::IsNullOrWhiteSpace($failedText)) {
        Write-Error "Helm package failed"
    }
    $(helm list)

    WaitForPodsInNamespace -namespace $namespace -interval 5 -Verbose

    # read tcp ports and update ngnix with those ports
    SetTcpPortsForStack -namespace $namespace -Verbose

    ShowUrlsAndPasswordsForRealtime -namespace "$namespace" -Verbose

    $certpassword = $(ReadSecretPassword certpassword $namespace)
    Write-Host "Certificate Password= $certpassword"

    Write-Host "Download the realtime tester from https://github.com/HealthCatalyst/Fabric.Realtime.Tester/releases"

    Read-Host -Prompt "Click ENTER to continue"

    Write-Verbose 'InstallRealtime: Done'
}

Export-ModuleMember -Function 'InstallRealtime'