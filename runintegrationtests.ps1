$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Set-StrictMode -Version Latest

# Set-Location $naPath

$ErrorActionPreference = "Stop"

Import-Module Pester

$VerbosePreference = "continue"

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
