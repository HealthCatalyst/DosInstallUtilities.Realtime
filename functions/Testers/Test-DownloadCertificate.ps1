<#
.SYNOPSIS
Test-DownloadCertificate

.DESCRIPTION
Test-DownloadCertificate

.INPUTS
Test-DownloadCertificate - The name of Test-DownloadCertificate

.OUTPUTS
None

.EXAMPLE
Test-DownloadCertificate

.EXAMPLE
Test-DownloadCertificate


#>
function Test-DownloadCertificate()
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $CertificateHost
    )

    Write-Verbose 'Test-DownloadCertificate: Starting'

    [string] $url = "http://$CertificateHost/certificates/client/fabricrabbitmquser_client_cert.p12"
    [System.Net.WebClient] $webClient = New-Object System.Net.WebClient
    $webClient.UseDefaultCredentials=$true
    [byte[]] $certdata = $webClient.DownloadData($url)

    Write-Host "----------- certificate ------------"
    Write-Host $certdata
    Write-Host "----------- end of certificate ------------"

    Write-Verbose 'Test-DownloadCertificate: Done'

    return @{
        CertData = $certdata
    }
}

Export-ModuleMember -Function 'Test-DownloadCertificate'