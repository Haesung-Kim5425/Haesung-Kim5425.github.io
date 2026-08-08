<#
.SYNOPSIS
    Builds the site and serves it locally at http://127.0.0.1:4000 for preview.

.DESCRIPTION
    Convenience wrapper so previewing the site is one command. It:
      1. puts the Ruby toolchain on PATH for this process only (Ruby was installed to
         C:\Ruby34-x64 and is deliberately not on the system PATH),
      2. re-syncs the bibliography from the source of truth,
      3. runs `bundle exec jekyll serve`.

    Nothing here publishes anything. This is local preview only.

.EXAMPLE
    pwsh -File bin\serve.ps1
#>

[CmdletBinding()]
param(
    # Where RubyInstaller put the toolchain.
    [string]$RubyBin = 'C:\Ruby34-x64\bin',

    # Skip the bibliography sync (e.g. when the source of truth is not reachable).
    [switch]$NoSync,

    [int]$Port = 4000
)

$ErrorActionPreference = 'Stop'
$siteRoot = Split-Path -Parent $PSScriptRoot

if (Test-Path -LiteralPath $RubyBin) {
    $env:Path = "$RubyBin;$env:Path"
}
if (-not (Get-Command ruby -ErrorAction SilentlyContinue)) {
    Write-Error "ruby not found. Expected it at $RubyBin. Install with: winget install RubyInstallerTeam.RubyWithDevKit.3.4"
    exit 1
}

if (-not $NoSync) {
    & (Join-Path $PSScriptRoot 'sync-sot.ps1')
    Write-Host ''
}

Push-Location $siteRoot
try {
    Write-Host "Serving at http://127.0.0.1:$Port  (Ctrl+C to stop)" -ForegroundColor Cyan
    bundle exec jekyll serve --port $Port --livereload
}
finally {
    Pop-Location
}
