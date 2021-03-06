# Modules

# Menus
. $PSScriptRoot\functions\Menus\ShowRealtimeMenu.ps1

# Helpers
. $PSScriptRoot\functions\Helpers\CreateSecretsForRealtime.ps1
. $PSScriptRoot\functions\Helpers\ShowUrlsAndPasswordsForRealtime.ps1

# Testers
. $PSScriptRoot\functions\Testers\Test-TcpPort.ps1
. $PSScriptRoot\functions\Testers\Test-SendingHL7.ps1
. $PSScriptRoot\functions\Testers\Test-DownloadCertificate.ps1
. $PSScriptRoot\functions\Testers\Install-Certificate.ps1
. $PSScriptRoot\functions\Testers\Test-RabbitMq.ps1

# Install
. $PSScriptRoot\functions\Install\InstallRealtime.ps1
