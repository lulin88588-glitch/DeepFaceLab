# Installs the Windows prerequisites for the native RTX 5090 runtime.
#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Invoke-CheckedNative {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Command,

        [Parameter(Mandatory = $true)]
        [string[]] $Arguments,

        [int[]] $AcceptedExitCodes = @(0, 3010)
    )

    Write-Host "Running: $Command $($Arguments -join ' ')"
    & $Command @Arguments
    $nativeExitCode = $LASTEXITCODE
    if ($nativeExitCode -notin $AcceptedExitCodes) {
        throw "$Command failed with exit code $nativeExitCode."
    }
    return $nativeExitCode
}

$winget = (Get-Command winget.exe -ErrorAction Stop).Source

Write-Host 'Installing WSL2 and Ubuntu 24.04...'
$wslExitCode = Invoke-CheckedNative -Command 'wsl.exe' -Arguments @(
    '--install',
    '--distribution', 'Ubuntu-24.04',
    '--no-launch',
    '--web-download'
)

Write-Host 'Installing Docker Desktop from the official winget source...'
$dockerExitCode = Invoke-CheckedNative -Command $winget -Arguments @(
    'install',
    '--id', 'Docker.DockerDesktop',
    '--exact',
    '--source', 'winget',
    '--silent',
    '--disable-interactivity',
    '--accept-package-agreements',
    '--accept-source-agreements'
)

$rebootPending = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') -or
    (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') -or
    ($wslExitCode -eq 3010) -or
    ($dockerExitCode -eq 3010)

Write-Host ''
Write-Host 'WSL2/Ubuntu and Docker Desktop installation commands completed.'
if ($rebootPending) {
    Write-Host 'REBOOT_REQUIRED=1'
    Write-Host 'Windows must be restarted before GPU container validation.'
}
else {
    Write-Host 'REBOOT_REQUIRED=0'
    Write-Host 'Start Docker Desktop, then run run_blackwell.ps1.'
}
