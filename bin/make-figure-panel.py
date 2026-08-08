#!/usr/bin/env python3
"""Compose the selected papers' figures into one panel image for the front page.

The five figures come from the academic record (achievements/figures/, referenced by
`preview` fields in the bibliography). Shown one-per-entry in the publication list they
scattered the page; collected into a single panel they read as one picture of the work.

Captions are read from the bibliography rather than typed here, so a venue or year cannot
drift from the entry it labels. Panels are laid out by aspect ratio: the wide figure gets
a full-width row of its own instead of being squeezed into a grid cell.

Run via bin/sync-sot.ps1, which calls this whenever a source figure changes. Running it
by hand is fine too:

    python bin/make-figure-panel.py
"""

from __future__ import annotations

import os
import re
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("Pillow is required: python -m pip install --user pillow")

HERE = os.path.dirname(os.path.abspath(__file__))
SITE = os.path.dirname(HERE)
BIB = os.path.join(SITE, "_bibliography", "papers.bib")
OUT = os.path.join(SITE, "assets", "img", "selected_work.png")

# Source figures are read from the academic record, not from inside the site.
#
# They used to be copied into assets/img/publication_preview/ and served. Once the panel
# replaced the per-entry figures nothing linked them any more, which left five publisher
# figures sitting at guessable URLs in a public repository with no copyright notice
# attached to them — the notice lives beside the panel. Unreferenced published files also
# have a way of being rediscovered later and reused stale.
#
# Only the composed panel is a site asset now. The individual figures stay in the record.
FIGDIR = os.path.join(SITE, "..", "achievements", "figures")

# Layout constants. Panel width is generous so the image stays sharp on a high-density
# screen; the page scales it down with CSS.
WIDTH = 1600
MARGIN = 28
GAP = 24
CAPTION_H = 34
BG = (255, 255, 255)
FRAME = (223, 226, 230)
CAPTION_FG = (90, 96, 104)


def load_font(size: int):
    """Prefer a real UI font; fall back rather than fail, since the panel is still
    readable with the bitmap default even if it is uglier."""
    for name in ("segoeui.ttf", "arial.ttf", "calibri.ttf", "DejaVuSans.ttf"):
        path = os.path.join(os.environ.get("WINDIR", "C:\\Windows"), "Fonts", name)
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                pass
    return ImageFont.load_default()


def bib_entries() -> dict[str, dict]:
    """Map preview filename -> {venue, year}. Entry bodies only: the header documents the
    convention with a sample `preview = {filename.png}` line, and counting that as a real
    entry is the false positive this project has now hit three times."""
    with open(BIB, encoding="utf-8") as fh:
        text = fh.read()
    out: dict[str, dict] = {}
    for m in re.finditer(r"(?ms)^@(?!string|preamble|comment)\w+\{(.*?)(?=^@|\Z)", text):
        body = m.group(1)
        prev = re.search(r"preview\s*=\s*\{([^}]+)\}", body)
        if not prev:
            continue
        venue = re.search(r"(?:journal|booktitle)\s*=\s*\{([^}]*)\}", body)
        year = re.search(r"year\s*=\s*\{(\d{4})\}", body)
        out[prev.group(1).strip()] = {
            "venue": re.sub(r"\s+", " ", venue.group(1)).strip() if venue else "",
            "year": year.group(1) if year else "",
        }
    return out


SHORT = {
    "IEEE Electron Device Letters": "IEEE EDL",
    "IEEE Transactions on Electron Devices": "IEEE TED",
    "Applied Physics Letters": "Appl. Phys. Lett.",
    "Nuclear Engineering and Technology": "Nucl. Eng. Technol.",
    "Solid-State Electronics": "Solid-State Electron.",
    "Current Applied Physics": "Curr. Appl. Phys.",
}


def caption_for(meta: dict) -> str:
    venue = SHORT.get(meta["venue"], meta["venue"])
    return f"{venue} {meta['year']}".strip()


def fit(img: Image.Image, box_w: int, box_h: int) -> Image.Image:
    """Scale to fit inside the box without cropping; publication figures must not lose
    axis labels or legends to a crop."""
    scale = min(box_w / img.width, box_h / img.height)
    return img.resize((max(1, int(img.width * scale)), max(1, int(img.height * scale))), Image.LANCZOS)


def main() -> int:
    meta = bib_entries()
    files = sorted(f for f in os.listdir(FIGDIR) if f.lower().endswith((".png", ".jpg", ".jpeg")))
    if not files:
        sys.exit(f"no figures in {FIGDIR}")

    images = [(f, Image.open(os.path.join(FIGDIR, f)).convert("RGB")) for f in files]
    # Widest figure last, on a row of its own: squeezing a 3:1 figure into a grid cell
    # shrinks it until its axis labels are unreadable.
    images.sort(key=lambda t: t[1].width / t[1].height)
    grid, wide = images[:-1], images[-1:]

    font = load_font(19)
    cell_w = (WIDTH - 2 * MARGIN - GAP) // 2

    rows: list[list[tuple[str, Image.Image]]] = [grid[i : i + 2] for i in range(0, len(grid), 2)]
    row_heights = []
    for row in rows:
        h = max(fit(im, cell_w, 10_000).height for _, im in row)
        row_heights.append(min(h, 340))
    wide_h = 0
    if wide:
        wide_h = min(fit(wide[0][1], WIDTH - 2 * MARGIN, 10_000).height, 300)

    total_h = (
        MARGIN
        + sum(h + CAPTION_H + GAP for h in row_heights)
        + (wide_h + CAPTION_H if wide else 0)
        + MARGIN
    )

    canvas = Image.new("RGB", (WIDTH, total_h), BG)
    draw = ImageDraw.Draw(canvas)

    def place(img: Image.Image, name: str, x: int, y: int, box_w: int, box_h: int) -> None:
        fitted = fit(img, box_w, box_h)
        # Centre in both axes. Figures in a row rarely share an aspect ratio, so
        # top-aligning them leaves the shorter one floating above a gap with its caption
        # stranded far below.
        px = x + (box_w - fitted.width) // 2
        py = y + (box_h - fitted.height) // 2
        canvas.paste(fitted, (px, py))
        draw.rectangle(
            [px - 1, py - 1, px + fitted.width, py + fitted.height], outline=FRAME, width=1
        )
        cap = caption_for(meta.get(name, {"venue": "", "year": ""}))
        if cap:
            tw = draw.textlength(cap, font=font)
            draw.text((x + (box_w - tw) / 2, y + box_h + 8), cap, font=font, fill=CAPTION_FG)

    y = MARGIN
    for row, h in zip(rows, row_heights):
        for i, (name, im) in enumerate(row):
            place(im, name, MARGIN + i * (cell_w + GAP), y, cell_w, h)
        y += h + CAPTION_H + GAP

    if wide:
        name, im = wide[0]
        place(im, name, MARGIN, y, WIDTH - 2 * MARGIN, wide_h)

    canvas.save(OUT, "PNG", optimize=True)
    print(f"wrote {os.path.relpath(OUT, SITE)}  {canvas.width}x{canvas.height}  {os.path.getsize(OUT):,} bytes")
    for name, _ in images:
        print(f"  {name:30} {caption_for(meta.get(name, {'venue': '', 'year': ''}))}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
