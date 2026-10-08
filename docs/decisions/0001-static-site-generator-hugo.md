# 0001. Static site generator: Hugo

- Status: accepted
- Date: 2026-10-07

## Context
Need: extremely fast output, EN/PL i18n, tags, RSS, image processing, build-time data fetching,
easy maintenance with Claude Code, minimal dependency churn.

## Options considered
1. **Hugo**: single Go binary, zero JS output, all features built in (i18n, taxonomies, RSS,
   AVIF/WebP images, remote data). Con: Go template syntax is terse; frequent deprecations.
2. **Zola**: single Rust binary, similar features. Con: smaller ecosystem, less AI training data.
3. **Eleventy**: flexible, JS templates. Con: Node toolchain, i18n/images via plugins.
4. **Astro**: modern, islands. Con: large npm tree; we don't need components.

## Decision
Hugo, version pinned in versions.env, own minimal theme (no third-party theme).

## Consequences
No node_modules. `make check` with `--panicOnWarning` catches deprecations on upgrades.
