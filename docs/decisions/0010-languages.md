# 0010. Languages: English (default), Ukrainian, Polish

- Status: accepted
- Date: 2026-10-10

## Context
The skeleton was bilingual from day one (English + Polish, Polish switched off until step 2.1).
On 2026-10-10 Kai added Ukrainian: English stays the main language, Ukrainian and Polish follow.
Expected readers are Europe plus the US and Canada (ADR 0008); hiring managers read English.

## Options considered
1. **English default under `/en/`, Ukrainian `/uk/`, Polish `/pl/`, all from the same templates**:
   one i18n file per language, every UI string required in all three (`make check`). Cost: three
   copies of every UI string; Cyrillic needs its own font files.
2. **English only, translations later**: least work now, but adding a language later is easier
   when the structure already expects it (URLs never change, templates already use i18n).
3. **Machine translation at build time**: rejected; the content guide forbids publishing raw
   machine translation.

## Decision
Option 1. Language order (switcher, `weight`): English 1, Ukrainian 2, Polish 3. The code is `uk`
(ISO 639-1 for the Ukrainian language, used in `lang="uk"` and the URL); `ua` is the country code
and would be wrong in `lang` and hreflang. Ukrainian and Polish stay `disabled = true` until 2.1.

## Consequences
- `i18n/uk.toml` exists now and `scripts/check-i18n.py` enforces it automatically (tested: removing
  one key fails with exit 1). Ukrainian strings were drafted by Claude; Kai reviews them.
- Fonts: Geist, Geist Mono and JetBrains Mono all have Cyrillic subsets on Google Fonts; they must
  be added (pinned, ADR 0009) before `uk` is enabled, or Cyrillic text falls back to the system
  font (seen in a test build). `unicode-range` keeps them off English pages.
- Step 2.1 grows: two languages to enable, hreflang for three, a switcher with three entries.
