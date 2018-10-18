<#
.SYNOPSIS
Install-Certificate

.DESCRIPTION
Install-Certificate

.INPUTS
Install-Certificate - The name of Install-Certificate

.OUTPUTS
None

.EXAMPLE
Install-Certificate

.EXAMPLE
Install-Certificate


#>

function Install-Certificate() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [byte[]]
        $certdata
        ,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $certpass
    )

    Write-Verbose 'Install-Certificate: Starting'

    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This script needs to be run As Admin"
        Break
    }

    # http://paulstovell.com/blog/x509certificate2

    $flags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet -bor [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet -bor [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable

    [System.Security.Cryptography.X509Certificates.X509Certificate2] $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(`
            $certdata, `
            $certpass, `
            $flags);

    [System.Security.Cryptography.X509Certificates.X509Store] $store = New-Object System.Security.Cryptography.X509Certificates.X509Store( `
            [System.Security.Cryptography.X509Certificates.StoreName]::My, `
            [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine);

    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite);

    $store.Add($cert);

    # [string] $userName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;

    # AddAccessToCertificate($cert);

    Write-Host "Saved certificate in Local Computer store on this machine: Personal->Certificates"

    Write-Verbose 'Install-Certificate: Done'
}

function AddAccessToCertificate() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $cert
    )

    [System.Security.Cryptography.RSACryptoServiceProvider] $rsa = $cert.PrivateKey

    [string] $keyfilepath = FindKeyLocation($rsa.CspKeyContainerInfo.UniqueKeyContainerName);

    [System.IO.FileInfo] $file = New-Object System.IO.FileInfo($keyfilepath + "\\" + $rsa.CspKeyContainerInfo.UniqueKeyContainerName);

    [System.Security.AccessControl.FileSecurity] $fs = $file.GetAccessControl();

    [System.Security.Principal.SecurityIdentifier] $sid = New-Object System.Security.Principal.SecurityIdentifier(`
            [System.Security.Principal.WellKnownSidType]::AuthenticatedUserSid, $null);

    $type = [System.Security.Principal.NTAccount]
    [System.Security.Principal.NTAccount] $account = $sid.Translate($type);

    [System.Security.AccessControl.FileSystemAccessRule] $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($account, `
            [System.Security.AccessControl.FileSystemRights]::Read, `
            [System.Security.AccessControl.AccessControlType]::Allow)
    $fs.AddAccessRule($accessRule);

    $file.SetAccessControl($fs);

    Write-Host "Added access to the cert's private key to all authenticated users"
}

function FindKeyLocation() {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $keyFileName
    )

    [string] $text1 = [System.Environment]::GetFolderPath([System.Environment.SpecialFolder]::CommonApplicationData);

    [string] $text2 = $text1 + '\Microsoft\Crypto\RSA\MachineKeys';

    [string[]] $textArray1 = [System.IO.Directory]::GetFiles($text2, $keyFileName);

    if ($textArray1.Length -gt 0) {
        return @{
            Location = $text2;
        }
    }

    [string] $text3 = [System.Environment]::GetFolderPath([System.Environment.SpecialFolder]::ApplicationData);
    [string] $text4 = $text3 + '\Microsoft\Crypto\RSA\';

    $textArray1 = [System.IO.Directory]::GetDirectories($text4);

    if ($textArray1.Length -gt 0) {
        foreach ($text5 in $textArray1) {
            $textArray1 = [System.IO.Directory]::GetFiles($text5, $keyFileName);
            if ($textArray1.Length -ne 0) {
                return @{
                    Location = $text5;
                }
            }
        }
    }

    Write-Error "Private key exists but is not accessible";

    return @{
        Location = $null
    }
}


Export-ModuleMember -Function 'Install-Certificate'