param([string]$OutputDir = '', [switch]$CaptureWave)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$out = if ($OutputDir) {
    if ([IO.Path]::IsPathRooted($OutputDir)) { $OutputDir } else { Join-Path $root $OutputDir }
} else { Join-Path ([IO.Path]::GetTempPath()) ("alu-exhaustive-" + [guid]::NewGuid().ToString('N')) }
$py = Get-Command py.exe -ErrorAction SilentlyContinue
if ($py) {
    $cmd = $py.Source
    $args = @('-3', (Join-Path $PSScriptRoot 'run_exhaustive.py'), '--output-dir', $out)
} else {
    $python = Get-Command python3.exe -ErrorAction SilentlyContinue
    if (-not $python) { throw 'Python 3.9+ is required for the result-aware runner' }
    $cmd = $python.Source
    $args = @((Join-Path $PSScriptRoot 'run_exhaustive.py'), '--output-dir', $out)
}
if ($CaptureWave) { $args += '--capture-wave' }
& $cmd @args
$code = $LASTEXITCODE
if ($code -ne 0) { exit $code }
Write-Output "ALU_REGRESSION_PASS portable_checks=1380 exhaustive_tuples=524288 output=$out"
