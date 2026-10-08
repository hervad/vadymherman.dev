# Stack review, October 2026

**Date:** 2026-10-08 · **Question:** are the tools and plan in this repo the right ones for a simple,
beautiful, functional and extremely fast personal site + blog, maintained with Claude Code + VS Code?
**Answer:** yes. Every tool choice holds; the research found ~20 small fixes, each mapped to a
roadmap step below.

## How this was researched

Four parallel research passes (tooling, hosting/serving, fast exemplar sites, front-end practice),
then spot checks of every repo-specific claim against the actual files.

Confidence labels used throughout:

- **[V] verified:** measured locally (`curl`, `hugo`, `gh api`), or read from official docs,
  MDN, caniuse, an RFC or a project's own source.
- **[LC] low confidence:** blog posts, forum threads, memory or aesthetic judgment. Check before
  relying on it.

Measurements were taken once, from a home connection in Poland (about 25–30 ms of local overhead),
so treat them as indicative, not benchmarks.

## Verdicts

| Layer | Choice | Verdict | Reason |
|---|---|---|---|
| Static site generator | Hugo 0.167.0 | Keep | Latest release (2026-09-28) [V]; single binary, no npm, zero JS output, i18n built in. Repo uses the current template system (v0.146+) and config keys (`label`, `locale`) [V]. |
| Web server | Caddy | Keep | Auto TLS, HTTP/3, serves precompressed `br`/`zstd`/`gzip` natively [V: caddyserver.com docs]. nginx needs third-party modules for brotli/zstd [LC]. |
| OS | AlmaLinux 10 | Keep | Works, but SELinux needs care (see 1.3 below). `rsync-rrsync` is in AppStream [V]. |
| Hosting | One OVHcloud VPS in Warsaw, no CDN (ADR 0005) | Keep, measure later | US penalty is first-view only and far under the LCP budget (see latency below). |
| Deploy | rsync → `releases/<sha>/` → symlink switch | Keep pattern, fix details | See 1.4 below. |
| Search | Pagefind 1.5.2 | Keep | Latest (2026-04-12) [V]; per-language index with Polish stemming [V]. |
| Comments | giscus, on demand | Keep + add "reply by email" | No cookies, no data collection [V: giscus privacy policy]; utterances stale since 2024-08 [V]. |
| Analytics | GoatCounter (self-hosted) + GoAccess | Keep | v2.7.0, single Go binary [V]. Plausible CE needs Docker + ClickHouse + ≥ 2 GB RAM [V]; Umami needs Postgres + Node. |
| GitHub projects | Build-time Python fetch → `data/` JSON | Keep | Fail-soft: keep last good JSON. `resources.GetRemote` is viable but couples builds to the network; client-side fetch breaks the 0 KB JS budget and hits the 60 req/h limit [V: GitHub rate-limit docs]. |

Alternatives considered for the generator: Zola (single binary, smaller ecosystem), Eleventy v3
(Node), Astro 7 (npm tree), Jekyll (Ruby, slow) [versions V via `gh api`; trade-offs LC].

The cost of Hugo is **API churn**: 0.163–0.167 moved image settings, deprecated
`resources.PostProcess` and moved `cleanDestinationDir` [V: release notes]. Mitigation: keep the
version pinned and read release notes on every upgrade (some deprecations exist only in docs and
produce no warning, see 0.1 below).

## Latency: does Warsaw without a CDN hold up?

Round-trip times from Poland [V]: Frankfurt ~40 ms, US East ~132–137 ms, US West ~195 ms.

| Scenario | Time to first byte |
|---|---|
| CDN edge from Poland (Cloudflare h3 / Bunny / GitHub Pages / Netlify) | 0.095–0.15 s [V] |
| Estimated US East → Warsaw, first visit | ~0.35 s h2, ~0.25 s h3 [inferred from V] |
| Estimated US West → Warsaw, first visit | ~0.5 s [inferred] |
| Observed: far single origin (caddyserver.com, ~190 ms RTT) | 0.58 s h2 vs 0.40 s h3 [V] |

A first visit costs 3–4 round trips (DNS, connection, TLS, request); later pages reuse the open
connection and cost one. HTTP/3 (QUIC) merges connection + TLS setup, saving one round trip.
With inlined CSS and no JS, even US West stays far under the 2.5 s "good" LCP threshold [V: web.dev].
**Conclusion:** ADR 0005 stands. Revisit in step 3.6 with a before/after measurement (Bunny pull
zone or Cloudflare proxy in front of the same Caddy origin).

## What extremely fast sites actually do

14 sites measured with `curl` on 2026-10-08 [V unless marked]. "Comp" = best encoding offered.

| Site | HTML raw → comp | Server / h3 | TTFB | External scripts | CSS | Web fonts |
|---|---|---|---|---|---|---|
| danluu.com | 22.7K → 6.4K | Cloudflare / h3 | 96 ms | 1 (CF beacon) | inline, tiny | none |
| herman.bearblog.dev | 11.8K → 3.8K | Cloudflare | 177 ms | 0 | inline | none |
| sive.rs | 13.5K → 4.7K | nginx | 612 ms | 0 | inline | 1 woff2 |
| tonsky.me | 14.5K → 4.5K | nginx | 168 ms | 1 | 2 external | self-hosted |
| brandur.org | 16.7K → 4.5K | S3+CloudFront / h3 | 136 ms | 1 (GoatCounter) | 9.5K | none |
| kevquirk.com | 49.4K → 8.4K | nginx | 141 ms | 1 (Prism) | 2.9K + inline | code font only |
| lea.verou.me | 18.4K → 4.0K | Netlify | 137 ms | 13 (Disqus) | 7.4K + icon font | icon font |
| simonwillison.net | 89.9K → 25.7K | Cloudflare / h3 | 100 ms | 1 (Plausible) | 11K immutable | none |
| jvns.ca | 147K → 25.9K | Netlify | 113 ms | 3 | 3.8K | none |
| gwern.net | 142K → 30.4K | Cloudflare / h3 | 197 ms | 3 | **52.6K** | in CSS |
| solar.lowtechmagazine.com | 22.7K → 5.4K | nginx | 327 ms | 2 | 6K | none |
| gohugo.io | 91.2K → 22.0K | Netlify | 143 ms | 3 | inline | TTF preloaded |
| mcmaster.com | 78.4K → 14.2K | hidden | 96 ms | 0 | inline | woff2 preloaded |
| mitchellh.com | 23.3K → 6.3K | Vercel | 135 ms | 8 (Next.js) | 13.8K | 3 woff2 |

None sent 103 Early Hints; only the four CDN-fronted sites offered HTTP/3. Our skeleton currently
sends **~1.5 KB compressed** per page with zero external requests [V].

**Patterns to copy**

1. Keep HTML under ~10 KB compressed; precompress br + gzip (br vs gzip differed < 5 %) [V].
2. Prose width ~60–75ch (sive `60ch`, bearblog `720px`); `<pre>` scrolls, never wraps [V].
3. System fonts (danluu, bearblog, simonw, jvns, brandur load none) [V].
4. `<meta name="color-scheme" content="light dark">` + CSS variables for dark mode; a tiny inline
   script only for a manual toggle (brandur) [V].
5. Inline CSS → one request per page (danluu, bearblog, sive, gohugo, mcmaster) [V].
6. Anything external is fingerprinted and cached `max-age=31536000, immutable` (simonw, gwern,
   gohugo) [V].
7. Speculation rules: inline JSON that prefetches links on hover (gohugo.io) [V].
8. Plain dated lists for posts and projects, not cards or thumbnails (danluu) [V structure; LC taste].
9. Syntax highlighting at build time (Hugo Chroma), not with a JS library [LC judgment].
10. A "colophon"/"uses" page showing the site's own response headers turns the infra into
    portfolio material [LC idea].

**Anti-patterns:** a third-party script per widget (13 Disqus scripts), a framework runtime for a
text page (8 Next.js chunks), huge CSS bundles (52.6K, full Bootstrap), preloading TTF instead of
WOFF2, Google Tag Manager [V by measurement; GTM size LC]. "Minimal" is not automatically fast:
paulgraham.com had 454 ms TTFB and no compression [V].

**Suggested direction for step 1.2** [LC judgment]: bearblog/danluu weight with tonsky/brandur
personality (one accent colour, a good type scale).

## Front-end facts that shape the plan

- **14 KB rule still holds roughly:** QUIC's initial window is capped at 14,720 bytes, mirroring
  TCP [V: RFC 9002 §7.2]. It's a guide, not a cliff [LC]. At ~1.5 KB per page, inlining CSS is
  clearly right.
- **Core Web Vitals "good":** LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1 at p75 [V: web.dev]. With no JS,
  INP is free; the risks are CLS (images without width/height) and LCP (lazy-loaded hero image).
- **bfcache:** never `unload`, never `Cache-Control: no-store` on HTML [V: web.dev].
- **Modern CSS that's safe now:** `light-dark()` + `color-scheme`, `:has()`, `@container` (all
  Baseline) [V]; `text-wrap: balance` ~89 % [V]; cross-document view transitions ~89 %, not
  Baseline, so enhancement only and off under reduced motion [V].
- **Speculation rules:** Chromium only, ~76 % of users [V]; needs a CSP allowance [LC].
- **Images:** Hugo 0.167 encodes AVIF (since 0.162), WebP and JPEG [V].
- **Copy button:** impossible without JS (Clipboard API is JS-only) [V]; `user-select: all` on
  one-liners is the zero-JS alternative [LC].
- **WCAG 2.2 additions that matter:** 2.4.11 Focus Not Obscured, 2.5.8 Target Size ≥ 24×24 px [V].
- **Security grade:** MDN HTTP Observatory A+ needs score ≥ 100; bonuses (CSP `default-src 'none'`,
  COOP, CORP, Referrer-Policy, frame-ancestors) only count once the base score is ≥ 90 [V:
  observatory source]. `.dev` is HSTS-preloaded as a whole TLD, so `preload` is redundant [V].
  Inline CSS needs a style hash in the CSP, not only scripts.

## Fixes found, by roadmap step

Each repo-specific item was checked against the file it names.

**0.1 Orientation**
- Retag the inventory IP placeholder `TODO(0.3)` (`infra/ansible/inventory/production.yml:1`).
- `layouts/baseof.html:2` uses `site.Language.Lang`, deprecated in docs since v0.158 with **no
  build warning** [V]; switch to the current field.
- `scripts/install-tools.sh` pipes `curl | tar` with no checksum check; Hugo and Pagefind both
  publish checksums [V].

**0.2 GitHub repo + CI**
- `ci.yml` uses `actions/checkout@v4` and `upload-artifact@v4`; latest is v7 [V]. Pin by commit
  SHA, set `persist-credentials: false`, pin `ubuntu-24.04`, add `timeout-minutes`.
- Add `.github/dependabot.yml` for the github-actions ecosystem.

**1.2 Design**
- Home page has no `<h1>` (`layouts/home.html`) [V].
- No Chroma CSS yet, so code blocks are uncoloured [V]. Use `css.ChromaStyles` with a dark mode
  selector driven by the same class as the theme toggle.
- `main.css`: compounding monospace size inside `pre`, focus styles only on `a` (Chroma emits
  focusable `pre`), nav doesn't wrap, reduced-motion block misses pseudo-elements.

**1.3 Server with Ansible**
- Install `policycoreutils-python-utils` **before** Caddy: the package's install script uses
  `semanage` to label the binary and ports, and silently skips it if missing, leaving Caddy
  unconfined [V: Fedora caddy.spec; LC that COPR matches]. Verify with `ls -Z /usr/bin/caddy` and
  `ps -eZ | grep caddy`.
- Install Caddy from COPR (2.11.x for epel-10) rather than EPEL (2.10.2) [V].
- firewalld: `services: [ssh, http, https, http3]` (the `http3` service is UDP 443) [V].
- Caddyfile (`roles/caddy/templates/Caddyfile.j2`):
  - L22–23: add a `file` condition so a 404 on a hashed path isn't cached as immutable [LC].
  - Add `Cache-Control: public, max-age=0, must-revalidate` for HTML.
  - L25–32: confirm headers reach error responses; move them into a snippet if not [LC].
  - L34–37: use `handle_errors 404` so 5xx/403 don't show the 404 page.
  - Replace Hugo's meta-refresh `public/index.html` with `redir / /en/ 302`.
  - L8: the `www` block needs a DNS record or certificate issuance keeps retrying.
- COPR has no security advisory data, so `dnf-automatic` security-only won't update Caddy [LC];
  plan a scheduled Ansible run or release watch.

**1.4 Deploy pipeline**
- rrsync only allows rsync, so the deploy key can't flip the symlink. Add a forced-command wrapper
  that accepts `activate <sha>` and does `ln -s … current.tmp && mv -Tf current.tmp current`
  (`ln -sfn` may not be atomic [LC]).
- That means the deploy user needs write access to the directory holding `current`, which
  conflicts with `group_vars/all.yml:8`.
- Use `rsync -c --link-dest`: Hugo rewrites every file's mtime, so default size+time comparison
  re-sends everything.
- Deploy job: protected `production` environment, pinned `known_hosts`, `cancel-in-progress: false`.

**1.6 Security headers + SEO**
- Home RSS includes About with `pubDate 0001` [V]: limit the feed to the `blog` section.
- `robots.txt` lacks a `Sitemap:` line [V].
- Hugo's embedded `schema.html` emits microdata, not JSON-LD [V]: write a small JSON-LD partial.
- Feed autodiscovery link missing on single pages [V].
- Add CSP (with script **and** style hashes, via `resources.Fingerprint "sha256"`), CORP,
  `frame-ancestors`. Skip COEP (breaks the giscus iframe). Drop HSTS `preload` (redundant on .dev).

**1.7 Launch (nice-to-have)**
- Speculation rules (`prefetch`, `moderate` eagerness).
- `@view-transition { navigation: auto }` inside `prefers-reduced-motion: no-preference`.

**2.5 Comments**
- Add a "reply by email" link next to giscus (0 KB, works for readers without GitHub).

**2.7 CI quality gates**
- Make `make check` report gzip/brotli sizes, not only raw bytes.

**3.6 Experiments**
- CDN before/after: Bunny pull zone or Cloudflare proxy in front of Caddy.
- HTTPS DNS record with `alpn="h3,h2"` for first-visit HTTP/3 [LC].

## Open items to verify (low confidence)

- COPR Caddy spec runs the same SELinux scriptlet as Fedora's.
- Caddy `header` directives apply to `handle_errors` responses.
- Caching behaviour of 404s on the fingerprinted matcher.
- `ln -sfn` atomicity.
- HTTPS DNS record enabling h3 on first visit.

## Sources

Official docs and specs (all [V]):
- Hugo: https://gohugo.io/templates/new-templatesystem-overview/,
  https://gohugo.io/configuration/languages/, https://gohugo.io/functions/hugo/data/,
  https://gohugo.io/methods/site/language/, https://gohugo.io/functions/resources/getremote/,
  https://gohugo.io/functions/css/chromastyles/, https://gohugo.io/configuration/imaging/,
  https://gohugo.io/templates/embedded/
- Caddy: https://caddyserver.com/docs/caddyfile/directives/file_server
- Fedora caddy package: https://src.fedoraproject.org/rpms/caddy
- Pagefind: https://pagefind.app/docs/multilingual/
- giscus privacy: https://github.com/giscus/giscus/blob/main/PRIVACY-POLICY.md
- Plausible CE: https://github.com/plausible/community-edition
- GitHub rate limits: https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api
- RFC 9002: https://www.rfc-editor.org/rfc/rfc9002.html
- web.dev: https://web.dev/articles/vitals, https://web.dev/articles/bfcache,
  https://web.dev/articles/extract-critical-css
- caniuse: https://caniuse.com/mdn-html_elements_script_type_speculationrules,
  https://caniuse.com/cross-document-view-transitions, https://caniuse.com/css-text-wrap-balance
- W3C WCAG 2.2: https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/
- MDN HTTP Observatory grader: https://github.com/mdn/mdn-http-observatory

Opinion pieces [LC]:
- Barry Pollard on the 14 KB rule: https://www.tunetheweb.com/blog/critical-resources-and-the-first-14kb/
