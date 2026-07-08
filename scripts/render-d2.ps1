param(
  [Parameter(Mandatory = $true)]
  [Alias("Input")]
  [string]$Source,

  [Parameter(Mandatory = $false)]
  [string]$Output,

  [Parameter(Mandatory = $false)]
  [switch]$Watch,

  [Parameter(Mandatory = $false)]
  [string]$Layout,

  [Parameter(Mandatory = $false)]
  [string]$Theme,

  [Parameter(Mandatory = $false)]
  [int]$Timeout = 10
)

$ErrorActionPreference = "Stop"

function Resolve-D2 {
  if (-not [string]::IsNullOrWhiteSpace($env:D2_BIN)) {
    if (Test-Path $env:D2_BIN) {
      return $env:D2_BIN
    }
    throw "D2_BIN is set but does not exist: $env:D2_BIN"
  }

  $defaultD2 = "D:\tools\d2\d2.exe"
  if (Test-Path $defaultD2) {
    return $defaultD2
  }

  $cmd = Get-Command d2 -ErrorAction SilentlyContinue
  if ($null -ne $cmd) {
    return $cmd.Source
  }

  throw "D2 CLI not found. Set D2_BIN, install D2 in PATH, or place d2.exe at D:\tools\d2\d2.exe."
}

if (-not (Test-Path $Source)) {
  throw "Input file does not exist: $Source"
}

if ([string]::IsNullOrWhiteSpace($Output)) {
  $Output = [System.IO.Path]::ChangeExtension($Source, ".svg")
}

$outputParent = Split-Path -Parent $Output
if (-not [string]::IsNullOrWhiteSpace($outputParent) -and -not (Test-Path $outputParent)) {
  New-Item -ItemType Directory -Force -Path $outputParent | Out-Null
}

$d2 = Resolve-D2

$argsList = @()
if ($Watch) {
  $argsList += "--watch"
}
if (-not [string]::IsNullOrWhiteSpace($Layout)) {
  $argsList += "--layout"
  $argsList += $Layout
}
if (-not [string]::IsNullOrWhiteSpace($Theme)) {
  $argsList += "--theme"
  $argsList += $Theme
}
if ($Timeout -gt 0) {
  $argsList += "--timeout"
  $argsList += $Timeout.ToString()
}
$argsList += $Source
$argsList += $Output

& $d2 @argsList
