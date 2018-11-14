<#
.SYNOPSIS
Shows product menu

.DESCRIPTION
ShowRealtimeMenu

.INPUTS
ShowRealtimeMenu - The name of ShowRealtimeMenu

.OUTPUTS
None

.EXAMPLE
ShowRealtimeMenu

.EXAMPLE
ShowRealtimeMenu


#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
function ShowRealtimeMenu() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $baseUrl
        ,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $namespace
        ,
        [Parameter(Mandatory = $true)]
        [bool]
        $local
        ,
        [bool]
        $isAzure = $true
    )

    Write-Verbose 'ShowRealtimeMenu: Starting'
    $userinput = ""
    while ($userinput -ne "q") {
        Write-Host "================ $namespace menu ================"
        Write-Host "------ Install -------"
        Write-Host "1: Install $namespace"
        Write-Host "------ Status --------"
        Write-Host "2: Show status of $namespace"
        Write-Host "3: Show $namespace urls & passwords"
        Write-Host "5: Show $namespace detailed status"
        Write-Host "6: Show $namespace logs"
        # Write-Host "8: Show DNS entries for /etc/hosts"
        Write-Host "9: Troubleshoot Ingresses"
        Write-Host "11: Show commands to SSH to $namespace containers"
        Write-Host "------ Delete data --------"
        Write-Host "12: Delete all data in $namespace"
        Write-Host "------ Testers --------"
        # Write-Host "31: Test interface engine"
        # Write-Host "32: Install Certificate on this machine (Needs Run As Administrator)"
        Write-Host "33: Test via RabbitMq tester"
        Write-Host "-----------"
        Write-Host "q: Go back to main menu"
        $userinput = Read-Host "Please make a selection"
        switch ($userinput) {
            '1' {
                $packageUrl = $kubeGlobals.realtimePackageUrl
                if ($local) {
                    $packageUrl = "$here\..\..\..\helm.realtime\fabricrealtime"
                    Write-Host "Loading package from $packageUrl"
                }
                $VerbosePreference = 'Continue'

                CreateSecretsForRealtime -namespace $namespace -Verbose

                if ($isAzure) {
                    InstallProductInAzure -namespace $namespace -packageUrl $packageUrl -local $local -Verbose
                }
                else {
                    CreateOnPremStorage -namespace $namespace

                    InstallStackInKubernetes `
                        -namespace $namespace `
                        -package $namespace `
                        -packageUrl $packageUrl `
                        -isOnPrem $true
                }
            }
            '2' {
                kubectl get 'deployments,pods,services,ingress,secrets,persistentvolumeclaims,persistentvolumes,nodes' --namespace=$namespace -o wide
            }
            '3' {
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
            }
            '5' {
                ShowStatusOfAllPodsInNameSpace "$namespace"
            }
            '6' {
                ShowLogsOfAllPodsInNameSpace "$namespace"
            }
            '9' {
                TroubleshootIngress "$namespace"
            }
            '11' {
                ShowSSHCommandsToContainers -namespace $namespace
            }
            '12' {
                Write-Warning "This will delete all data in this namespace and clear out any secrets"
                Do { $confirmation = Read-Host "Do you want to continue? (y/n)"}
                while ([string]::IsNullOrWhiteSpace($confirmation))

                if ($confirmation -eq "y") {

                    DeleteHelmPackage -package $namespace -Verbose

                    if($isAzure){

                        DeleteNamespaceAndData -namespace "$namespace" -isAzure $isAzure -Verbose
                    }
                    else
                    {
                        CleanOutNamespace -namespace $namespace

                        if ($isAzure) {
                            DeleteAzureStorage -namespace $namespace
                        }
                        else {
                            DeleteOnPremStorage -namespace $namespace
                        }

                        DeleteAllSecretsInNamespace -namespace $namespace -Verbose
                    }
                }
            }
            '13' {
                RunRealtimeTester -baseUrl $baseUrl
            }
            '31' {
                $loadBalancerInfo = $(GetLoadBalancerIPs)
                # $loadBalancerInternalIP = $loadBalancerInfo.InternalIP
                # Test-TcpPort -InterfaceEngineHost $($loadBalancerInfo.ExternalIP) -port 3307
                Test-TcpPort -InterfaceEngineHost $($loadBalancerInfo.ExternalIP) -port 6661
                Test-SendingHL7 -InterfaceEngineHost $($loadBalancerInfo.ExternalIP)
            }
            '32' {
                $loadBalancerInfo = $(GetLoadBalancerIPs)
                $result = $(Test-DownloadCertificate -CertificateHost $($loadBalancerInfo.ExternalIP))
                $certpassword = $(ReadSecretPassword certpassword $namespace)
                Install-Certificate -certdata $($result.CertData) -certpass "$certpassword"
            }
            '33' {
                if($isAzure){
                    $loadBalancerInfo = $(GetLoadBalancerIPs -Verbose)
                    Write-Host "Host= $($loadBalancerInfo.ExternalIP)"
                }
                else {
                    $certhostname = $(ReadSecretValue certhostname $namespace)
                    Write-Host "Host=$certhostname"
                }
                $certpassword = $(ReadSecretPassword certpassword $namespace)
                Write-Host "Certificate Password= $certpassword"

                Write-Host "Download the tester from https://github.com/HealthCatalyst/Fabric.Realtime.Tester/releases"
            }
            'q' {
                return
            }
        }
        $userinput = Read-Host -Prompt "Press Enter to continue or q to go back to top menu"
        if ($userinput -eq "q") {
            return
        }
        [Console]::ResetColor()
        Clear-Host
    }

    Write-Verbose 'ShowRealtimeMenu: Done'
}

Export-ModuleMember -Function 'ShowRealtimeMenu'