
Import-Module psake

function Invoke-TestFailure
{
    param(
        [parameter(Mandatory=$true)]
        [validateSet('Unit','Integration','Acceptance')]
        [string]$TestType,

        [parameter(Mandatory=$true)]
        $PesterResults
    )

    $errorID = if($TestType -eq 'Unit'){'UnitTestFailure'}elseif($TestType -eq 'Integration'){'InetegrationTestFailure'}else{'AcceptanceTestFailure'}
    $errorCategory = [System.Management.Automation.ErrorCategory]::LimitsExceeded
    $errorMessage = "$TestType Test Failed: $($PesterResults.FailedCount) tests failed out of $($PesterResults.TotalCount) total test."
    $exception = New-Object -TypeName System.SystemException -ArgumentList $errorMessage
    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $exception,$errorID, $errorCategory, $null

    Write-Output "##vso[task.logissue type=error]$errorMessage"
    Throw $errorRecord
}

FormatTaskName "--------------- {0} ---------------"

Properties {
    $TestsPath = "$PSScriptRoot\Tests"
    $TestResultsPath = "$TestsPath\Results"
    $ArtifactPath = "$Env:BUILD_ARTIFACTSTAGINGDIRECTORY"
    $ModuleArtifactPath = "$ArtifactPath\Modules"
    $MOFArtifactPath = "$ArtifactPath\MOF"
    $ConfigPath = "$PSScriptRoot\Configs"
    $RequiredModules = @(@{Name='xDnsServer';Version='1.7.0.0'}, @{Name='xNetworking';Version='2.9.0.0'}) 
}

Task Default -depends BLIZZ

Task GenerateEnvironmentFiles -Depends Clean {
     Exec {& $PSScriptRoot\DevEnv.ps1 -OutputPath $ConfigPath}
}

Task Bar -Depends Clean, BLIZZ

Task BLIZZ 
{
    "testing 1, 2, 3."
}




Task FOO -depends BLIZZ
{
    "this is FOO..."
} 

Task Clean {
    "Starting Cleaning enviroment..."
    #Make sure output path exist for MOF and Module artifiacts
    New-Item $ModuleArtifactPath -ItemType Directory -Force 
    New-Item $MOFArtifactPath -ItemType Directory -Force 

    # No need to delete Artifacts as VS does it automatically for each build

    #Remove Test Results from previous runs
    New-Item $TestResultsPath -ItemType Directory -Force
    Remove-Item "$TestResultsPath\*.xml" -Verbose 

    #Remove ConfigData generated from previous runs
    Remove-Item "$ConfigPath\*.psd1" -Verbose

    #Remove modules that were installed on build Agent
    foreach ($Resource in $RequiredModules)
    {
        $Module = Get-Module -Name $Resource.Name
        if($Module  -And $Module.Version.ToString() -eq  $Resource.Version)
        {
            Uninstall-Module -Name $Resource.Name -RequiredVersion $Resource.Version
        }
    }

    $Error.Clear()
}
