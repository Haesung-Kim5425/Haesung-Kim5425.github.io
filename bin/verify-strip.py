"""Prove that stripping comments changed nothing but comments.

bin/sync-sot.ps1 removes full-line comments when it copies achievements/profile.yml and
achievements/record.yml into _data/. The records are annotated in Korean by the hub
session with working notes -- withheld values, approval dates, instructions to renderers
-- and this repository is public, so copying the notes publishes the reasoning behind the
page. One of them quoted a token from the private block list while explaining that it
must never be published.

Removing lines from a YAML file is only safe if it removes nothing that carries meaning,
and the dangerous case is the folded block scalars this profile uses for the biography and
the research summary: inside one, a line beginning with '#' is text. The stripper tracks
block scalars, but tracking is an argument, not evidence.

This is the evidence. It parses the source and the generated copy and compares the
resulting structures. Equal structures mean the copy says exactly what the source says.

    python bin/verify-strip.py

Exit 0 if every pair matches, 1 otherwise. Run it after changing Remove-CommentLines.
"""

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("PyYAML is required: pip install pyyaml")

HERE = Path(__file__).resolve().parent
SITE = HERE.parent
RECORDS = SITE.parent / "achievements"

PAIRS = [
    (RECORDS / "profile.yml", SITE / "_data" / "profile.yml"),
    (RECORDS / "record.yml", SITE / "_data" / "record.yml"),
]

# Values the sync deliberately rewrites on the way through, so that a difference in them
# is expected rather than a fault. Subscripts: the records write formulae the way the CV
# needs them for .tex (HfZrO_x), and the web copy carries real subscript characters.
# En dashes: the record writes "--" for the same reason.
def normalise(value):
    if isinstance(value, dict):
        return {k: normalise(v) for k, v in value.items()}
    if isinstance(value, list):
        return [normalise(v) for v in value]
    if isinstance(value, str):
        out = value.replace("--", "–")
        for i in range(10):
            out = out.replace("_" + str(i), chr(0x2080 + i))
        out = out.replace("_x", "ₓ")
        return out
    return value


def walk(a, b, path=""):
    """Yield a description of every place two structures disagree."""
    if type(a) is not type(b):
        yield f"{path or '(root)'}: type {type(a).__name__} vs {type(b).__name__}"
        return
    if isinstance(a, dict):
        for key in sorted(set(a) | set(b)):
            if key not in a:
                yield f"{path}.{key}: only in the copy"
            elif key not in b:
                yield f"{path}.{key}: only in the source"
            else:
                yield from walk(a[key], b[key], f"{path}.{key}")
    elif isinstance(a, list):
        if len(a) != len(b):
            yield f"{path}: {len(a)} items in the source, {len(b)} in the copy"
            return
        for i, (x, y) in enumerate(zip(a, b)):
            yield from walk(x, y, f"{path}[{i}]")
    elif a != b:
        yield f"{path}:\n      source: {a!r}\n      copy  : {b!r}"


def main():
    failures = 0
    for src, dst in PAIRS:
        if not src.exists():
            print(f"  MISS  {src} does not exist")
            failures += 1
            continue
        if not dst.exists():
            print(f"  MISS  {dst} does not exist -- run bin/sync-sot.ps1")
            failures += 1
            continue

        source = normalise(yaml.safe_load(src.read_text(encoding="utf-8")))
        copy = yaml.safe_load(dst.read_text(encoding="utf-8"))
        differences = list(walk(source, copy, ""))

        stripped = src.read_text(encoding="utf-8").count("\n") - dst.read_text(
            encoding="utf-8"
        ).count("\n")
        if differences:
            failures += 1
            print(f"  FAIL  {src.name}: {len(differences)} difference(s)")
            for d in differences[:10]:
                print(f"        {d}")
        else:
            print(f"  ok    {src.name}: identical after parsing ({stripped} lines removed)")

    if failures:
        print("\nThe copy does not say what the source says. Do not deploy.")
        return 1
    print("\nComment stripping is lossless.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
