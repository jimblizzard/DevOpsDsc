# Create the DNSServer MOF

Write-Host "Conpiling DNSServer..."

$ConfigPath = "$PSScriptRoot\Configs"

. "$ConfigPath\DNSServer.ps1"

DNSServer -ConfigurationData "$ConfigPath\DevEnv.psd1" -OutputPath "$MOFArtifactPath\DevEnv\"
