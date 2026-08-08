<#
.SYNOPSIS
    Builds the site and checks the built output for anything that must never be published.

.DESCRIPTION
    Run this before deploying. It is the last gate before a public URL exists.

    Every other check in this repository looks at sources. This one looks at the built
    site, which is what visitors actually get -- a value can reach the output through a
    theme layout, a data file, a plugin or a page front matter without ever appearing in
    a page source, so scanning sources is not the same check.

    What it looks for:

      * the never-publish items from `exclude` in _data/profile.yml -- phone numbers,
        street address, GPA, date of birth -- as patterns, plus any DOI named there
        (currently a same-name-author paper held back pending identification);
      * leftover al-folio demo content, which ships with a real person's name and
        citation record and must not appear on someone else's site;
      * internal editing notes: HTML comments are served to anyone who opens the page
        source, so notes belong in Liquid comments that stop at the build.

    A finding is a failure, not a warning. Exit 1 means do not deploy.

.EXAMPLE
    pwsh -File bin\check-public.ps1
#>

[CmdletBinding()]
param(
    [string]$RubyBin = 'C:\Ruby34-x64\bin',
    [switch]$SkipBuild   # scan an existing _site_check from a previous run
)

$ErrorActionPreference = 'Stop'
$siteRoot = Split-Path -Parent $PSScriptRoot
$outDir   = Join-Path $siteRoot '_site_check'

if (Test-Path -LiteralPath $RubyBin) { $env:Path = "$RubyBin;$env:Path" }

if (-not $SkipBuild) {
    if (-not (Get-Command ruby -ErrorAction SilentlyContinue)) {
        Write-Error "ruby not found (expected at $RubyBin). Cannot build, so cannot check the output."
        exit 1
    }
    # Invoke as a native process, not with '&'. Dot-calling a .ps1 does not reliably set
    # $LASTEXITCODE, so the sync's refusal codes (3 = unsafe source) would be read as
    # success -- the exact failure this script exists to prevent.
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'sync-sot.ps1') | Out-Null
    $syncExit = $LASTEXITCODE
    if ($syncExit -ne 0) { Write-Error "sync-sot.ps1 refused or failed (exit $syncExit). Fix that before deploying."; exit 1 }

    Push-Location $siteRoot
    try {
        if (Test-Path -LiteralPath $outDir) { Remove-Item -LiteralPath $outDir -Recurse -Force }
        $env:JEKYLL_ENV = 'production'
        Write-Host "Building (production) ..." -ForegroundColor Cyan
        bundle exec jekyll build --destination $outDir --quiet
        if ($LASTEXITCODE -ne 0) { Write-Error "jekyll build failed."; exit 1 }
    }
    finally { Pop-Location }
}

if (-not (Test-Path -LiteralPath $outDir)) { Write-Error "No built site at $outDir."; exit 1 }

$allFiles = Get-ChildItem -LiteralPath $outDir -Recurse -File -Include *.html, *.json, *.xml, *.txt

# Scan authored output only. Third-party libraries the theme bundles (the distill
# template, chart and math runtimes) are full of things that trip content patterns --
# SVG path coordinates that look like a phone number, an example.com in a docstring --
# and none of it is authored here. Leaving them in produced two failures on a clean
# site, and a check that cries wolf gets ignored, which is worse than not having it.
$skipPattern = '(?i)[\\/]assets[\\/](js|libs)[\\/]|\.map$'
$files   = $allFiles | Where-Object { $_.FullName -notmatch $skipPattern }
$skipped = $allFiles.Count - $files.Count

Write-Host "Scanning $($files.Count) built files ($skipped third-party asset files skipped) ..." -ForegroundColor Cyan

$checks = @(
    @{ name = 'phone number (international)'; pattern = '(?<!\d)\+\d{1,3}[-. ]\d{2,4}[-. ]\d{3,4}[-. ]\d{3,4}(?!\d)' }
    @{ name = 'phone number (local)';         pattern = '(?<!\d)\d{3}[-. ]\d{3}[-. ]\d{4}(?!\d)' }
    @{ name = 'office street address';        pattern = '(?i)\d{3,5}\s+Mitch\s+Daniels' }
    @{ name = 'date of birth';                pattern = '(?<!\d)19\d{2}-\d{2}-\d{2}(?!\d)' }
    @{ name = 'GPA';                          pattern = '(?<!\d)[0-4]\.\d{1,2}\s*/\s*4\.5(?!\d)' }
    @{ name = 'al-folio demo content';        pattern = '(?i)\b(einstein|example\.com|your-?name|555 your)\b' }
)

# DOIs the record says to withhold. Read from the profile rather than hard-coded, so the
# list is maintained in one place and a newly withheld paper is picked up automatically.
$profilePath = Join-Path $siteRoot '_data\profile.yml'
if (Test-Path -LiteralPath $profilePath) {
    $profileText = Get-Content -LiteralPath $profilePath -Raw -Encoding UTF8
    $inExclude = $false
    foreach ($line in ($profileText -split "`n")) {
        if ($line -match '^[A-Za-z_]') { $inExclude = ($line -match '^exclude\s*:') }
        if (-not $inExclude) { continue }
        foreach ($d in [regex]::Matches($line, '10\.\d{4,9}/[^\s"'')]+')) {
            $checks += @{ name = "withheld DOI $($d.Value)"; pattern = [regex]::Escape($d.Value) }
        }
    }
}
else {
    Write-Warning "_data/profile.yml not found -- withheld-DOI list could not be loaded. Run bin/sync-sot.ps1."
}

$failures = 0
foreach ($c in $checks) {
    $hits = $files | Select-String -Pattern $c.pattern -List
    if ($hits) {
        $failures++
        Write-Host ("  FAIL  " + $c.name) -ForegroundColor Red
        foreach ($h in $hits | Select-Object -First 5) {
            $rel = $h.Path.Substring($outDir.Length).TrimStart('\')
            $snippet = ($h.Matches[0].Value -replace '\s+', ' ')
            if ($snippet.Length -gt 90) { $snippet = $snippet.Substring(0, 90) + '...' }
            Write-Host "          $rel : $snippet"
        }
    }
    else {
        Write-Host ("  ok    " + $c.name) -ForegroundColor DarkGray
    }
}

# --------------------------------------------------------------------------------------
# Internal notes: checked against SOURCES, not the built output.
#
# jekyll-minifier strips HTML comments from the production build, so an internal note
# written as <!-- ... --> never reaches the deployed pages. It does reach the local
# preview, which is what gets shown around before a deploy, and it would reach production
# the moment minification is turned off or the comment lands somewhere the minifier does
# not process. Scanning the production output for these would be a check that cannot
# fail -- worse than no check, because it reads as assurance.
#
# So the rule is enforced where the mistake is made: notes in page and include sources
# belong in {% comment %} blocks, which Jekyll drops unconditionally.
# --------------------------------------------------------------------------------------
Write-Host ""
Write-Host "Checking sources for internal notes in HTML comments ..." -ForegroundColor Cyan

$noteWords   = 'DO NOT|SOURCING RULE|READ BEFORE EDITING|hub session|never-publish|source of truth|APPROVED TEXT'
$notePattern = "(?s)<!--(?:(?!-->).)*?(?:$noteWords)(?:(?!-->).)*?-->"
$srcDirs = @('_pages', '_includes', '_layouts', '_news') |
    ForEach-Object { Join-Path $siteRoot $_ } |
    Where-Object { Test-Path -LiteralPath $_ }

$noteHits = @()
if ($srcDirs) {
    $noteHits = Get-ChildItem -Path $srcDirs -Recurse -File -Include *.md, *.html, *.liquid |
        Select-String -Pattern $notePattern -List
}
if ($noteHits) {
    $failures++
    Write-Host "  FAIL  internal note written as an HTML comment" -ForegroundColor Red
    foreach ($h in $noteHits) {
        Write-Host "          $($h.Path.Substring($siteRoot.Length).TrimStart('\')) : line $($h.LineNumber)"
    }
    Write-Host "        Use {% comment %} ... {% endcomment %} instead; Jekyll drops those at build." -ForegroundColor Yellow
}
else {
    Write-Host "  ok    internal notes are all in Liquid comments" -ForegroundColor DarkGray
}

Write-Host ""
if ($failures -gt 0) {
    Write-Host "$failures check(s) FAILED. Do not deploy." -ForegroundColor Red
    Write-Host "The built output is left at $outDir for inspection."
    exit 1
}
Write-Host "All checks passed." -ForegroundColor Green
Remove-Item -LiteralPath $outDir -Recurse -Force
exit 0
