# Create the DNSServer MOF

Write-Output "Compiling DNSServer..."

$ConfigPath = "$PSScriptRoot\Configs"
$ArtifactPath = "$Env:BUILD_ARTIFACTSTAGINGDIRECTORY"
$MOFArtifactPath = "$ArtifactPath\MOF"

Exec {& . .\DNSServer.ps1}

DNSServer -ConfigurationData "$ConfigPath\DevEnv.psd1" -OutputPath "$MOFArtifactPath\DevEnv\"
