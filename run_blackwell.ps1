param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $DeepFaceLabArgs
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$composeFile = Join-Path $repoRoot 'compose.blackwell.yml'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker was not found. Enable WSL2 and install Docker Desktop with its WSL2 backend.'
}
if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw 'WSL was not found. Run enable_wsl2_admin.ps1 from an Administrator PowerShell.'
}
if (-not (Get-Command nvidia-smi.exe -ErrorAction SilentlyContinue)) {
    throw 'nvidia-smi was not found. Install a current NVIDIA Windows driver.'
}

& wsl.exe --status *> $null
if ($LASTEXITCODE -ne 0) {
    throw 'WSL2 is not ready. Run enable_wsl2_admin.ps1 as Administrator and restart Windows if requested.'
}

docker compose version *> $null
if ($LASTEXITCODE -ne 0) {
    throw 'Docker Compose v2 is unavailable. Update Docker Desktop.'
}
docker info --format '{{.ServerVersion}}' *> $null
if ($LASTEXITCODE -ne 0) {
    throw 'The Docker engine is not running. Start Docker Desktop and enable its WSL2 backend.'
}

$computeCapabilities = @(
    nvidia-smi.exe --query-gpu=compute_cap --format=csv,noheader,nounits
)
if ($LASTEXITCODE -ne 0 -or $computeCapabilities.Count -eq 0) {
    throw 'Unable to query the NVIDIA GPU compute capability.'
}
$hasBlackwellGpu = $false
foreach ($capability in $computeCapabilities) {
    $parsedCapability = $null
    if ([version]::TryParse($capability.Trim(), [ref] $parsedCapability) -and
        $parsedCapability -ge [version]'12.0') {
        $hasBlackwellGpu = $true
        break
    }
}
if (-not $hasBlackwellGpu) {
    throw "No SM 12.0 RTX 50-series GPU was found (reported: $($computeCapabilities -join ', '))."
}

Push-Location $repoRoot
try {
    docker compose -f $composeFile build
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    if (-not $DeepFaceLabArgs -or $DeepFaceLabArgs.Count -eq 0) {
        $DeepFaceLabArgs = @('verify_blackwell_training.py')
    }
    docker compose -f $composeFile run --rm deepfacelab @DeepFaceLabArgs
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
