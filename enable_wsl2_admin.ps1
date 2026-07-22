# Run this script from an elevated PowerShell window.
# WSL may request a reboot before Ubuntu can start.
#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

& wsl.exe --install --distribution Ubuntu-24.04
if ($LASTEXITCODE -ne 0) {
    throw "WSL2 installation failed with exit code $LASTEXITCODE."
}

Write-Host 'WSL2/Ubuntu installation requested successfully.'
Write-Host 'Restart Windows if prompted, then install Docker Desktop with the WSL2 backend.'
