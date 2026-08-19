<#
.SYNOPSIS
    Installs this repository's git hooks. Run once per clone.

.DESCRIPTION
    Git does not track the contents of .git/hooks, so the hooks have to be written into
    place. Currently one hook is installed:

      pre-commit - refuses the commit if _bibliography/papers.bib is older than the
                   publication source of truth it is copied from. Without it a stale
                   bibliography can be committed and published silently, because the
                   GitHub Actions build never sees the source of truth and so cannot
                   notice the drift.

    Safe to re-run: it overwrites the hook with the current version.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$siteRoot = Split-Path -Parent $PSScriptRoot
$hookDir  = Join-Path $siteRoot '.git\hooks'

if (-not (Test-Path -LiteralPath $hookDir)) {
    Write-Error "No .git\hooks directory at $hookDir. Is this a git repository? Run 'git init' first."
    exit 1
}

$preCommit = @'
#!/bin/sh
# No `set -e`: the freshness check signals "stale" with exit 2, and under set -e that
# would abort the hook before the status could be read -- blocking the commit with no
# explanation at all. Exit codes are handled explicitly below.
sync_script="$(git rev-parse --show-toplevel)/bin/sync-sot.ps1"
[ -f "$sync_script" ] || { echo "pre-commit: bin/sync-sot.ps1 not found; skipping." >&2; exit 0; }
sot="$(git rev-parse --show-toplevel)/../achievements/publications.bib"
[ -f "$sot" ] || { echo "pre-commit: source of truth not reachable; skipping." >&2; exit 0; }
check_output=$(powershell -NoProfile -ExecutionPolicy Bypass -File "$sync_script" -Check 2>&1)
status=$?
if [ "$status" -eq 2 ]; then
    echo "" >&2
    # Print what the check said rather than naming a file. This message used to read
    # "papers.bib is out of date" whatever was stale, from when the bibliography was the
    # only thing copied in; it since sent someone to diff a file that was current while
    # the profile was the stale one. The check names the artefact -- let it.
    echo "pre-commit: BLOCKED - a copied artefact is out of date." >&2
    echo "$check_output" >&2
    echo "  Committing now would publish a stale copy." >&2
    echo "  Fix:  pwsh -File bin/sync-sot.ps1  &&  git add -A" >&2
    echo "" >&2
    exit 1
fi
if [ "$status" -eq 3 ]; then
    echo "" >&2
    echo "pre-commit: BLOCKED - the publication source of truth is not valid BibTeX." >&2
    echo "$check_output" >&2
    exit 1
fi
if [ "$status" -ne 0 ]; then
    echo "pre-commit: freshness check could not run (exit $status); allowing commit." >&2
    echo "$check_output" >&2
fi
exit 0
'@

$target = Join-Path $hookDir 'pre-commit'
[System.IO.File]::WriteAllText($target, ($preCommit -replace "`r`n", "`n"), (New-Object System.Text.UTF8Encoding($false)))

Write-Host "Installed pre-commit hook at $target" -ForegroundColor Green
Write-Host "It blocks commits while any copied artefact is older than the record it comes from."
