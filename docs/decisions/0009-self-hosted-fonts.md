# 0009. Self-hosted web fonts: Geist, Geist Mono, JetBrains Mono

- Status: accepted
- Date: 2026-10-09

## Context
The design brief allowed system fonts only, or one self-hosted font "if clearly justified". The
Signal design (docs/design-spec.md, chosen in the lab on 2026-10-08) depends on its type: Geist for
headline and body, Geist Mono for the labels, menu and build strip, JetBrains Mono for code. Fonts
are the heaviest thing on an otherwise ~4 KB page, and CLAUDE.md forbids web fonts and CDNs
without an explicit decision.

## Options considered
1. **Google Fonts' pre-split woff2 subsets, downloaded once, committed, SHA-256 pinned**: exactly
   the files the lab measured; no tools; `unicode-range` splitting already done. Cost: we trust
   Google's subsetting and must refresh by hand (`make fonts` after editing URL + hash).
2. **Official releases, subset ourselves with pyftsubset**: full control over glyphs and features,
   possibly smaller files; adds a Python tool (pip) and a build step to explain and maintain.
3. **System fonts only**: 0 KB and no decision needed, but loses the look Kai chose; system UI
   fonts differ per OS, so the headline would look different on every machine.
4. Loading from fonts.googleapis.com at runtime: ruled out (third-party request on every visit,
   visitor IPs sent to Google, extra DNS + TLS round trips; against the no-CDN rule).

## Decision
Option 1. Six files (latin + latin-ext for each family) live in `static/fonts/` with their OFL
licenses; `scripts/fetch-fonts.sh` pins URL + SHA-256 per file, and `make check` runs its
`--verify` mode. `@font-face` rules (generated, `assets/css/fonts.css`) use `font-display: swap`
and Google's `unicode-range`, so a browser downloads only the files a page needs.

## Consequences
- Measured: English page 51.3 KB of fonts (Geist 28.7 + Geist Mono 22.6), +20.7 KB with code;
  Polish pages add the latin-ext files (+16.1 / +14.4 / +7.2 KB). Downloaded on the first visit,
  then cached. The 30 KB page budget counts HTML + CSS only, so fonts sit outside it.
- `swap` shows text immediately in a fallback font, then swaps in Geist: a small layout shift is
  possible; fallback metrics can be tuned later if Lighthouse flags it.
- Licenses: SIL OFL 1.1 allows self-hosting and redistribution; the license files ship with the fonts.
- A changed or corrupted font file fails `make check` (tested by flipping one byte: exit 1).
