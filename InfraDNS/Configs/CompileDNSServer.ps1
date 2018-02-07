# Create the DNSServer MOF

Write-Output "Conpiling DNSServer..."

$ConfigPath = "$PSScriptRoot\Configs"

. "$ConfigPath\DNSServer.ps1"

DNSServer -ConfigurationData "$ConfigPath\DevEnv.psd1" -OutputPath "$MOFArtifactPath\DevEnv\"
