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
    [switch]$SkipBuild,   # scan an existing _site_check from a previous run

    # The record's private block list. A parameter only so that the refusal below can be
    # exercised -- pointing it at a file that does not exist must stop the run.
    [string]$BlockListPath
)

$ErrorActionPreference = 'Stop'
$siteRoot = Split-Path -Parent $PSScriptRoot
$outDir   = Join-Path $siteRoot '_site_check'

if (Test-Path -LiteralPath $RubyBin) { $env:Path = "$RubyBin;$env:Path" }

# --------------------------------------------------------------------------------------
# Strings that must never be published, from the record.
#
# achievements/exclude_private.yml lists them: ids of manuscripts under submission, a
# collaborator held back pending the owner's re-confirmation, internal sample codenames.
# The list lives OUTSIDE this repository and is read across the boundary, because a list
# of things not to publish, stored in a public repository, publishes them. Nothing copies
# it in; bin/sync-sot.ps1 refuses to run if a copy ever appears here.
#
# Loaded before the build so a missing list fails in a second rather than a minute, and
# it is a FAILURE, not a warning: an empty list would let every one of these checks pass
# vacuously, and a check that cannot fail reads as assurance while providing none. That
# pattern has already cost this site once.
# --------------------------------------------------------------------------------------
$blockPath = $BlockListPath
if (-not $blockPath) { $blockPath = Join-Path $siteRoot '../achievements/exclude_private.yml' }
if (-not (Test-Path -LiteralPath $blockPath)) {
    Write-Error "Block list not found: $blockPath`nThe hub session owns it. Cannot verify the build without it -- do not deploy."
    exit 1
}
$blockText = Get-Content -LiteralPath $blockPath -Raw -Encoding UTF8
if ($blockText -match '(?m)^\s*public_safe\s*:\s*true\s*(#.*)?$') {
    Write-Error "$blockPath declares public_safe: true. That is not the private block list -- refusing to run against the wrong file."
    exit 1
}
# Sequence items under any top-level key, with the key kept for the report. Comment lines
# are skipped: the file's header quotes several of these strings while explaining them.
$blocked = @()
$blockKey = ''
foreach ($line in ($blockText -split "`n")) {
    $t = $line.TrimEnd()
    if ($t.TrimStart().StartsWith('#') -or $t.Trim() -eq '') { continue }
    $k = [regex]::Match($t, '^([A-Za-z_][A-Za-z0-9_]*)\s*:')
    if ($k.Success) { $blockKey = $k.Groups[1].Value; continue }
    $m = [regex]::Match($t, '^\s*-\s*"?([^"#]+?)"?\s*(#.*)?$')
    if ($m.Success) { $blocked += @{ key = $blockKey; value = $m.Groups[1].Value } }
}
if ($blocked.Count -eq 0) {
    Write-Error "$blockPath parsed to zero strings. Refusing to report a pass on an empty list."
    exit 1
}
Write-Host "Block list: $($blocked.Count) strings from $(Split-Path -Leaf $blockPath)." -ForegroundColor Cyan

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

    # The sync drops the records' comments on the way in, so that the hub's working notes
    # stop at this repository's boundary. Removing lines from a YAML file is only safe
    # while it removes nothing that carries meaning -- proven by parsing both files and
    # comparing, not by reading the stripper.
    & python (Join-Path $PSScriptRoot 'verify-strip.py')
    if ($LASTEXITCODE -ne 0) { Write-Error "verify-strip.py failed: the copies in _data no longer say what the records say."; exit 1 }

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
    # al_comments renders a red "misconfigured" panel when giscus is switched on without
    # repo_id / category / category_id. It is a visible error box on a public page, and it
    # appears only in the built output, so nothing in the sources would reveal it.
    @{ name = 'giscus misconfiguration panel'; pattern = '(?i)giscus comments misconfigured' }
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

foreach ($b in $blocked) {
    $checks += @{ name = "blocked string ($($b.key))"; pattern = "(?i)" + [regex]::Escape($b.value); secret = $b.value }
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
# The same strings, checked against what else this repository publishes.
#
# The built site is not the whole public surface. This repository is itself public, so
# every tracked source file is readable at github.com even when nothing renders it -- and
# the CV PDF is served verbatim, so its text is published without passing through Jekyll
# at all. A block list that only looked at built HTML would miss both.
# --------------------------------------------------------------------------------------
Write-Host ""
Write-Host "Checking tracked sources and the CV PDF for blocked strings ..." -ForegroundColor Cyan

Push-Location $siteRoot
try { $tracked = @(& git ls-files) } finally { Pop-Location }
if ($tracked.Count -eq 0) { Write-Error "git ls-files returned nothing -- cannot check tracked sources."; exit 1 }
$trackedFiles = $tracked |
    Where-Object { $_ -notmatch '(?i)^assets/(js|libs)/' -and $_ -notmatch '(?i)\.(pdf|png|jpe?g|gif|webp|ico|woff2?|ttf|eot|map)$' } |
    ForEach-Object { Get-Item -LiteralPath (Join-Path $siteRoot $_) -ErrorAction SilentlyContinue }

# Get-Item, not the path string. Select-String searches the CONTENT of file objects but
# the TEXT of strings, so a pipeline of paths silently greps the file names -- which is
# what this scan did at first: it read every name and no content, and reported "ok".
#
# The count is asserted for the same reason. An earlier version mangled the separator,
# 53 of the 72 paths resolved to nothing, and the scan again reported "ok" having read
# only the repository root. Both were caught by injecting a blocked string and demanding
# a failure. Neither would have been caught by reading the output of a clean run.
$expectedTracked = @($tracked | Where-Object { $_ -notmatch '(?i)^assets/(js|libs)/' -and $_ -notmatch '(?i)\.(pdf|png|jpe?g|gif|webp|ico|woff2?|ttf|eot|map)$' }).Count
if ($trackedFiles.Count -ne $expectedTracked) {
    Write-Error "Only $($trackedFiles.Count) of $expectedTracked tracked files could be opened. Refusing to report on a partial scan."
    exit 1
}

$cvPdf = Join-Path $siteRoot 'assets\pdf\Haesung_Kim_CV.pdf'
$cvText = ''
if (Test-Path -LiteralPath $cvPdf) {
    # PyMuPDF, because nothing in the Ruby toolchain here reads PDF text. If it is not
    # installed the PDF cannot be checked, and an unchecked public file is a failure --
    # the CV is the likeliest place for a manuscript id to appear.
    $cvText = & python -c "import fitz,sys; print(''.join(p.get_text() for p in fitz.open(sys.argv[1])))" $cvPdf 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  FAIL  CV PDF could not be read (needs: pip install pymupdf)" -ForegroundColor Red
        Write-Host "        $cvText"
        $failures++
        $cvText = ''
    }
    # Positive control on the extraction itself. If PyMuPDF returned nothing -- a layout
    # it cannot read, a scanned page, a silent failure -- every string below would be
    # "absent" from an empty string and the CV would pass unread.
    elseif ($cvText -notmatch 'Haesung') {
        Write-Error "CV text extraction produced no recognisable text ($($cvText.Length) chars). Cannot check the PDF, so cannot pass it."
        exit 1
    }
}
else { Write-Warning "No CV PDF at $cvPdf -- nothing to check." }

# One exemption, and only one: the `exclude` block of _data/profile.yml.
#
# That block is the record's declaration of what must never be published, and one of its
# entries is the same-name author's DOI -- so the block always contains a blocked string
# by definition. Failing on it would make the gate fail on every clean build, and a gate
# that fails on a correct file is switched off within the week. The declaration is scoped
# by line number rather than by pattern, so a blocked string anywhere else in the same
# file still fails.
$exemptLines = @{}
$profileForExempt = Join-Path $siteRoot '_data/profile.yml'
if (Test-Path -LiteralPath $profileForExempt) {
    $key = (Get-Item -LiteralPath $profileForExempt).FullName
    $exemptLines[$key] = New-Object System.Collections.Generic.HashSet[int]
    $n = 0
    $inExcl = $false
    foreach ($line in (Get-Content -LiteralPath $profileForExempt -Encoding UTF8)) {
        $n++
        if ($line -match '^[A-Za-z_]') { $inExcl = ($line -match '^exclude\s*:') }
        if ($inExcl) { [void]$exemptLines[$key].Add($n) }
    }
}

$srcFail = 0
foreach ($b in $blocked) {
    $pat = "(?i)" + [regex]::Escape($b.value)
    $hits = @()
    if ($trackedFiles) {
        $hits += $trackedFiles | Select-String -Pattern $pat |
            Where-Object { -not ($exemptLines.ContainsKey($_.Path) -and $exemptLines[$_.Path].Contains($_.LineNumber)) }
    }
    $inCv = ($cvText -ne '' -and $cvText -match $pat)
    if ($hits.Count -gt 0 -or $inCv) {
        $failures++; $srcFail++
        Write-Host ("  FAIL  blocked string '" + $b.value + "' (" + $b.key + ")") -ForegroundColor Red
        foreach ($h in $hits | Select-Object -First 5) {
            Write-Host "          $($h.Path.Substring($siteRoot.Length).Trim('\','/')) : line $($h.LineNumber)"
        }
        if ($inCv) { Write-Host "          assets\pdf\Haesung_Kim_CV.pdf (PDF text)" }
    }
}
if ($srcFail -eq 0) {
    Write-Host "  ok    $($blocked.Count) blocked strings absent from $($trackedFiles.Count) tracked files and the CV PDF" -ForegroundColor DarkGray
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
