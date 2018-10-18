$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Set-StrictMode -Version Latest
Set-PSDebug -Strict

# Set-Location $naPath

$ErrorActionPreference = "Stop"

Import-Module Pester

$VerbosePreference = "continue"

Import-Module -Name "PSRabbitMq" -MinimumVersion "0.3.1"

$module = "DosInstallUtilities.Azure"
Get-Module "$module" | Remove-Module -Force
Import-Module "$here\..\$module\$module.psm1" -Force

$module = "DosInstallUtilities.Kube"
Get-Module "$module" | Remove-Module -Force
Import-Module "$here\..\$module\$module.psm1" -Force

$module = "DosInstallUtilities.Menu"
Get-Module "$module" | Remove-Module -Force
Import-Module "$here\..\$module\$module.psm1" -Force

$module = "DosInstallUtilities.Realtime"
Get-Module "$module" | Remove-Module -Force
Import-Module "$here\$module.psm1" -Force

# Invoke-Pester "$here\Module.Tests.ps1"


Invoke-Pester "$here\functions\Testers\Test-SendingHL7.Tests.ps1" -Tag 'Integration' -Verbose

Invoke-Pester "$here\functions\Testers\Test-DownloadCertificate.Tests.ps1" -Tag 'Integration' -Verbose

Invoke-Pester "$here\functions\Testers\Install-Certificate.Tests.ps1" -Tag 'Integration' -Verbose