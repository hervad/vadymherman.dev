# Design spec: Signal

Locked on 2026-10-08 after comparing two directions in an interactive lab
([docs/design/signal-lab.html](design/signal-lab.html); open it in a browser, the lab loads its
preview fonts from Google Fonts, the real site will not). Roadmap step 1.2 builds from this file.

**Direction:** dark, cinematic, precise. Big tight headline, one accent per theme, hairline
structure, the site's real build facts along the top, terminal-style code blocks.
Inspired by 2advanced.com and wodniack.dev for mood, built with danluu.com-level weight.

## Colour tokens

Each theme has its own accent (a normal design-system pattern: one semantic token, two values).

| Token | Light | Dark | Used for |
|---|---|---|---|
| `--bg` | `#f5f6f8` | `#0d1014` | page |
| `--surface` | `#ffffff` | `#141820` | inline code |
| `--ink` | `#121418` | `#e7eaef` | text, headline |
| `--muted` | `#454c58` | `#8d95a3` | secondary text, labels, dates |
| `--line` | `#d2d6dc` | `#232a34` | hairlines |
| `--accent` | `#6a3fd6` violet | `#ffe14d` yellow | eyebrow labels, link underline, mark slash |
| `--ok` | `#1f7a4d` | `#5fd39a` | "nominal" status dot, "live" |
| `--term-bg` | `#11141a` | `#07090c` | code blocks (dark in both themes) |
| `--term-ink` / `--term-dim` | `#d9dee6` / `#7d8696` | `#d9dee6` / `#7d8696` | code text / code chrome |
| syntax | keyword `#8fb8ff`, string `#a8d8a0`, prompt = dark accent | same | code |

**Contrast (WCAG AA needs 4.5:1 for text), measured with the WCAG formula:**

| Pair | Light | Dark |
|---|---|---|
| ink on bg | 17.1:1 | 15.8:1 |
| muted on bg | 8.0:1 | 6.3:1 |
| accent on bg | 5.9:1 | 14.6:1 |
| ok on bg | 4.9:1 | 10.2:1 |
| term-ink on term-bg | 13.6:1 | 14.8:1 |
| term-dim on term-bg | 5.0:1 | 5.4:1 (the lab's `#6f7888` was 4.5:1, raised) |

Lesson from the lab: dark gold `#806500` passed contrast (5.1:1) in light mode but looked muddy.
Yellow is a dark-background colour; light mode gets its own accent instead.

## Typography

| Role | Face | Weights | Where |
|---|---|---|---|
| Headline + body | **Geist** (variable) | 400–800 | everything readable |
| Labels | **Geist Mono** (variable) | 400–800 | build strip, eyebrow, section labels, menu, dates, `VH/dev` mark |
| Code | **JetBrains Mono** | 400 | code blocks and inline code only |

- Headline: weight 800, tracking `-0.05em`, line-height `.95`, size `clamp(2.6rem, 13cqi, 5.4rem)`.
- Labels: 11 px, uppercase, tracking `.12em`.
- Menu (Writing / Projects / About): **MONO CAPS**, Geist Mono 11.5 px, weight 500, tracking `.1em`.
- Prose measure: about 62–68ch.

**Font cost, measured** (woff2 subsets, first visit only, cached afterwards):

| Page | Geist | Geist Mono | JetBrains Mono | Total |
|---|---|---|---|---|
| English (latin) | 28.7 KB | 22.6 KB | 20.7 KB, code pages only | 51.3 KB, 72.0 KB with code |
| Polish (latin + latin-ext) | 44.8 KB | 36.9 KB | 27.8 KB, code pages only | 81.7 KB, 109.5 KB with code |

Self-hosted (no CDN), split by `unicode-range` so English pages never download Polish glyphs,
`font-display: swap`. Fonts are new to this project: needs ADR 0009 before step 1.2 adds them.

## Layout

- **Build strip** (top): `BUILD <sha> · ORIGIN WAW · PAGE <size> · PROTO h3` and a green
  "nominal" dot. Values come from the real build (Hugo + CI).
- **Nav:** `VH/dev` mark left (slash in the accent), menu right, theme switch at the end.
- **Home:** eyebrow `LINUX · KVM · PLATFORM RELIABILITY`, two-line name headline, one-sentence
  intro, then Projects (title, one-line description, status) and Writing (date column + title).
- **Post:** eyebrow link back to Writing, headline, mono meta line (date · reading time · tags),
  prose, code blocks with a title bar (file name left, line range or language right).
- Footer: copyright left, `0 KB JavaScript · served by Caddy` right.

## Interaction

| Element | Behaviour |
|---|---|
| Links | **Sweep**: a 1.5 px accent underline grows from the left, 0.25 s |
| List rows | **Spotlight**: hovering or tabbing to a row dims the others to 32% (`:has()`, only on devices that hover; keyboard via `:focus-visible`). Readout flip: **off** |
| Page load | **Boot**: build-strip values type in one after another, then the status dot lights (about 1 s, once) |
| Theme switch | **Eclipse + label**: pill with the eclipse icon and the current theme word (LIGHT / DARK). Circular reveal from the switch via View Transitions; instant where unsupported |

- All motion is off under `prefers-reduced-motion: reduce`.
- Theme switch is a real `<button>` with a fixed name ("Dark theme") and `aria-pressed`,
  visible focus ring, at least 24×24 px.
- Default theme follows the OS (`prefers-color-scheme`); a click overrides it and is remembered.

## Budgets

- CSS under 14 KB, inlined. The lab's Signal CSS with every option measured 12.5 KB unminified;
  the final CSS keeps only the chosen options.
- 0 KB JavaScript on load except the inline theme script (allowed by CLAUDE.md); the switch
  handler and circular reveal are a few hundred bytes more, also inline.

## Dropped (easy to bring back)

- Workbench direction (light, editorial, hand-drawn).
- Readout flip on rows; amber title/text on selected rows (only applied to the "Select" row style,
  which was replaced by Spotlight).
- Highlighter light mode (yellow as a marker behind black text): the runner-up for light mode.

## Open questions for step 1.2

- Getting back to "follow my OS" after clicking the switch: a third state, or a small "auto"
  link? Proposed: the label shows `AUTO` until the first click; decide during the build.
- Whether the build strip's `PAGE <size>` can be computed at build time in Hugo or needs a CI step.
