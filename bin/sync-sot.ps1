<#
.SYNOPSIS
    Copies the publication SoT into the site's bibliography. One-way, SoT -> site.

.DESCRIPTION
    The single source of truth for publications lives outside this repository, at

        ../achievements/publications.bib     (relative to the site root)

    al-folio / jekyll-scholar can only read a .bib file that lives inside the site root,
    and the GitHub Actions build only ever checks out this repository -- so the SoT has to
    be copied in. This script is that copy, and it is the ONLY sanctioned way for
    _bibliography/papers.bib to change.

    Run it before every commit that touches publications. It is safe to run repeatedly.

.NOTES
    Direction is one-way by design. Edits made directly to _bibliography/papers.bib are
    destroyed the next time this runs. Fix the SoT instead.
#>

[CmdletBinding()]
param(
    # Path to the SoT .bib. Defaults to the hub's achievements/ directory, two levels up.
    [string]$SotPath,

    # Where jekyll-scholar reads from (see `scholar.bibliography` in _config.yml).
    [string]$DestPath,

    # Report what would change without writing anything.
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

# Resolve the script's own directory in the body, not in a param() default.
# $PSScriptRoot is not populated during parameter binding when the script is launched as
# `powershell -File bin/sync-sot.ps1` (which is how the git pre-commit hook calls it), so
# a Join-Path default there fails with "Cannot bind argument to parameter 'Path'".
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $SotPath)  { $SotPath  = Join-Path $here '..\..\achievements\publications.bib' }
if (-not $DestPath) { $DestPath = Join-Path $here '..\_bibliography\papers.bib' }

if (-not (Test-Path -LiteralPath $SotPath)) {
    Write-Error "SoT not found: $SotPath`nThe hub session owns this file. Ask it to create the file before syncing."
    exit 1
}

$SotPath  = (Resolve-Path -LiteralPath $SotPath).Path
$destDir  = Split-Path -Parent $DestPath
if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }

$sotText = Get-Content -LiteralPath $SotPath -Raw -Encoding UTF8
if ($null -eq $sotText) { $sotText = '' }
# Drop a leading BOM: it would otherwise end up mid-file, after the header we prepend.
# (Written as an escape, not a literal, so this script stays pure ASCII on disk --
#  Windows PowerShell 5.1 reads a BOM-less .ps1 as ANSI and would corrupt a literal.)
$sotText = $sotText.TrimStart([char]0xFEFF)

# Neutralise '@' inside comment lines.
#
# BibTeX has no line-comment syntax: '%' lines are simply text outside any entry, and
# bibtex-ruby skips them by scanning forward to the next '@'. So an '@' that appears
# inside a '%' note -- e.g. a tally line reading "total 24 = @article 21 + ..." -- makes
# the parser open an entry mid-comment and the whole file fails with
#   Failed to parse BibTeX on value "21" (NUMBER) ["@", "article"]
# taking the publications page down with it.
#
# Only lines whose first non-whitespace character is '%' are touched, so no entry field,
# author, title or DOI can be altered by this. The SoT itself is left alone -- the fix
# belongs there, and the warning below says so.
$commentAtPattern = '(?m)^([ \t]*%.*)$'
$sanitised = [regex]::Replace($sotText, $commentAtPattern, {
    param($m)
    $line = $m.Groups[1].Value
    if ($line.Contains('@')) { $line.Replace('@', '[at]') } else { $line }
})
$commentAtCount = ([regex]::Matches($sotText, $commentAtPattern) | Where-Object { $_.Groups[1].Value.Contains('@') }).Count
if ($commentAtCount -gt 0) {
    Write-Warning "$commentAtCount comment line(s) in the SoT contain '@'. Rewritten to '[at]' in the copy so bibtex-ruby can parse the file."
    Write-Warning "Ask the hub session to remove '@' from '%' comment lines in achievements/publications.bib -- as written, that file is not valid BibTeX."
    $sotText = $sanitised
}

# Count real BibTeX entries so the operator sees whether the site will actually have
# anything to show. @string / @preamble / @comment are not publications.
$entryMatches = [regex]::Matches($sotText, '(?m)^\s*@(?!string\b|preamble\b|comment\b)([A-Za-z]+)\s*\{')
$entryCount   = $entryMatches.Count
$byType = $entryMatches | Group-Object { $_.Groups[1].Value.ToLower() } | Sort-Object Name

$stamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
$header = @"
% ============================================================================
% GENERATED FILE - DO NOT EDIT.
%
% Copied verbatim from the publication source of truth:
%     achievements/publications.bib   (owned by the Academic Profile hub session)
%
% Any edit made here is overwritten the next time bin/sync-sot.ps1 runs. To change
% what the website shows, change the SoT and re-run:
%
%     pwsh -File bin/sync-sot.ps1
%
% Synced: $stamp   |   entries: $entryCount
% ============================================================================

"@

$newText = $header + $sotText

$oldBody = ''
if (Test-Path -LiteralPath $DestPath) {
    $oldRaw = Get-Content -LiteralPath $DestPath -Raw -Encoding UTF8
    if ($null -ne $oldRaw) {
        # Strip a previously generated header so an unchanged SoT does not look like a diff.
        #
        # Match through the closing banner line and its single line break. Do not require a
        # blank line after it: PowerShell here-strings drop the newline before the closing
        # "@, so the header ends with exactly one newline. Requiring two made this never
        # match, which reported every file as changed and would have made the pre-commit
        # freshness check block every commit.
        $oldBody = [regex]::Replace($oldRaw, '(?s)^% =+.*?^% =+[ \t]*\r?\n', '', 'Multiline')
    }
}

$changed = ($oldBody -ne $sotText)

Write-Host "SoT   : $SotPath"
Write-Host "Site  : $DestPath"
Write-Host "Entries: $entryCount" -NoNewline
if ($byType) { Write-Host ("  (" + (($byType | ForEach-Object { "$($_.Name)=$($_.Count)" }) -join ', ') + ")") } else { Write-Host "" }

if ($entryCount -eq 0) {
    Write-Warning "The SoT contains no BibTeX entries. The Publications page will render EMPTY."
    Write-Warning "Ask the hub session to run the ORCID -> Zotero -> DOI-verification sync first."
}

if ($Check) {
    if ($changed) { Write-Host "CHECK: out of date -- run without -Check to sync." -ForegroundColor Yellow; exit 2 }
    Write-Host "CHECK: up to date." -ForegroundColor Green
    exit 0
}

# Write without a BOM: bibtex-ruby chokes on a leading U+FEFF.
[System.IO.File]::WriteAllText($DestPath, $newText, (New-Object System.Text.UTF8Encoding($false)))

if ($changed) { Write-Host "Synced (content changed)." -ForegroundColor Green }
else          { Write-Host "Synced (content identical; header timestamp refreshed)." -ForegroundColor Green }
