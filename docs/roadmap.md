# Roadmap

One step per session. `/next` picks the first unchecked step. Each step lists what it delivers,
what you learn, and how we know it's done. Steps marked **(you)** are things only you can do
(payments, accounts, writing); Claude prepares a checklist and waits.

"Research fixes" sub-bullets come from docs/research/2026-10-stack-review.md (details and sources there).

## Phase 0: Set up the workshop

- [ ] **0.1 Orientation.** `make tools` and `make check` pass on Fedora; `git init`, first commit.
  Claude walks through the repo layout and how a Markdown file becomes an HTML page.
  - Learn: Hugo's build pipeline (content → templates → public/), why tool versions are pinned.
  - Done when: `make serve` shows the site at localhost:1313 and you can explain the folders.
  - Research fixes: retag inventory IP `TODO(0.3)`; replace deprecated `site.Language.Lang` in
    baseof.html (no build warning for it); verify Hugo/Pagefind checksums in install-tools.sh.
- [ ] **0.2 GitHub repo + CI. (you + Claude)** Create the GitHub repo, push, CI goes green.
  - Learn: what GitHub Actions does on each push; reading a workflow file.
  - Done when: the CI badge is green and the `public` artifact downloads.
  - Research fixes: actions v4 → current, pinned by commit SHA; `persist-credentials: false`;
    pin `ubuntu-24.04`; `timeout-minutes`; add `.github/dependabot.yml` for github-actions.
- [ ] **0.3 Domain + VPS. (you)** Register the domain (Cloudflare Registrar, .dev), order the VPS
  (OVHcloud VPS-1, Warsaw, AlmaLinux 10), add your SSH key. Claude then replaces every placeholder.
  - Learn: DNS records (A, AAAA, CAA), what a registrar vs a DNS host does.
  - Done when: `ssh` works with your key, `dig +short yourdomain` returns the VPS IP, no
    `example.dev` left in the repo.

## Phase 1: MVP (target: one weekend per 2–3 steps)

- [ ] **1.1 How the templates work.** Guided tour of layouts/: baseof + blocks, partials, lookup
  order, `.Pages` vs `site.RegularPages`. Small exercise: add reading time to posts.
  - Done when: Claude made the change and you can explain how it works (what each line does and
    why).
- [ ] **1.2 Design.** Follow docs/design-brief.md: Claude proposes a design plan (palette, type
  scale, layout wireframe), you pick, then it's implemented in main.css. Add a no-flash dark/light
  toggle and a /styleguide/ page (draft, not in nav) showing every element in both themes.
  - Done when: Lighthouse accessibility 100, both themes checked, CSS < 14 KB.
  - Research fixes: home page `<h1>`; Chroma CSS (dark styles keyed to the toggle's class);
    monospace size inside `pre`; `:focus-visible` beyond links; nav wraps; reduced-motion covers
    pseudo-elements. Direction: bearblog/danluu weight, tonsky/brandur personality.
- [ ] **1.3 Server with Ansible.** Implement roles in order: base → users_ssh → firewall → selinux
  → caddy. First run everything against a **local AlmaLinux 10 KVM guest** (add
  inventory/local.yml), then the real VPS. Each role: explain → write → `--check --diff` → apply →
  re-run to prove idempotency.
  - Learn: idempotency, handlers, templates, SELinux contexts, why HTTP/3 needs UDP 443.
  - Done when: second run shows `changed=0`; `curl -I https://yourdomain` returns 200 over h2;
    site_root/current serves a placeholder page.
  - Research fixes: install `policycoreutils-python-utils` before Caddy (else it runs unconfined;
    check `ls -Z`, `ps -eZ`); Caddy from COPR; firewalld `http3` service; Caddyfile: `file`
    condition on the immutable matcher, HTML `Cache-Control`, headers on error pages,
    `handle_errors 404`, `redir / /en/`, www DNS record; plan Caddy updates (COPR has no advisories).
- [ ] **1.4 Deploy pipeline.** Deploy job in GitHub Actions: build → precompress (brotli, gzip) →
  rsync to releases/<sha>/ → atomic symlink switch → smoke test (build SHA meta tag) → keep last 5
  releases. Separate manual "rollback" workflow. Restricted deploy key (rrsync), pinned host key.
  - Learn: atomic renames, why symlink switching avoids half-deployed sites, least privilege.
  - Done when: a push to main is live in < 2 min, and a rollback is tested once.
  - Research fixes: forced-command wrapper for `activate <sha>` (rrsync can't flip symlinks;
    `mv -Tf` a temp link); reconcile deploy permissions with group_vars/all.yml:8;
    `rsync -c --link-dest`; protected `production` environment, `cancel-in-progress: false`.
- [ ] **1.5 Real content. (you write, Claude edits)** Home intro, About, hand-written Projects page
  (3–5 projects: problem → approach → result), first real post. Delete hello-world.
- [ ] **1.6 Security headers + SEO.** CSP (hashes for inline scripts), HSTS, Open Graph/Twitter
  meta, JSON-LD (Person, BlogPosting), sitemap check, robots.txt.
  - Done when: MDN HTTP Observatory A+, SSL Labs A+, Lighthouse 100 on all four categories.
  - Research fixes: RSS limited to `blog` (About shows up dated 0001); `Sitemap:` in robots.txt;
    own JSON-LD partial (Hugo's is microdata); feed link on all pages; CSP with script **and**
    style hashes; CORP + `frame-ancestors`; no COEP (breaks giscus); no HSTS `preload` (.dev is
    preloaded).
- [ ] **1.7 Launch.** Launch checklist (links, 404, RSS validates, mobile check), announce.
  Write the first ADR-based post: "Why Hugo + Caddy + AlmaLinux".
  - Nice-to-have: speculation rules (prefetch on hover); view transitions under
    `prefers-reduced-motion: no-preference`.

## Phase 2: Features

- [ ] **2.1 Polish version.** Enable `pl` in hugo.toml, hreflang + x-default, language switcher that
  never 404s, untranslated-post handling, PL RSS. Translate Home + About yourself.
- [ ] **2.2 GitHub projects data.** scripts/fetch_github.py (build-time, GITHUB_TOKEN, fail-soft)
  → data/github/repos.json; data/projects.yaml for curated EN/PL blurbs; daily scheduled build.
- [ ] **2.3 Images.** Markdown image render hook: AVIF/WebP/JPEG `<picture>`, srcset, width/height,
  lazy loading. Auto-generated Open Graph images per post.
- [ ] **2.4 Search.** Pagefind index after build, loaded only when the search box is focused or `/`
  is pressed; per-language results.
- [ ] **2.5 Comments.** giscus via GitHub Discussions, injected only when scrolled near or clicked;
  `comments: false` front matter switch. Plus a "reply by email" link (0 KB).
- [ ] **2.6 Analytics.** GoatCounter as a systemd service (new Ansible role) behind Caddy on
  stats.<domain>; cookieless; privacy page EN/PL; GoAccess report from Caddy logs.
- [ ] **2.7 CI quality gates.** HTML validation, lychee link checks (internal on PRs, external
  weekly), Lighthouse CI with byte budgets. `make check` reports gzip/brotli sizes, not raw bytes.

## Phase 3: SRE polish

- [ ] **3.1 Monitoring node.** Second small VPS: Uptime Kuma (rootless Podman + Quadlet), public
  status page, TLS-expiry and downtime alerts.
- [ ] **3.2 Metrics.** Caddy metrics + node_exporter → Prometheus/Grafana (or Grafana Cloud free).
- [ ] **3.3 Backups.** restic for /etc, Caddy data, GoatCounter DB; restore tested and documented.
- [ ] **3.4 SLOs + runbooks.** docs/slo.md (99.9 %, p95 TTFB), runbooks: site down, cert failure,
  disk full, rollback.
- [ ] **3.5 Hardening extras.** CrowdSec with the Caddy collection; Molecule tests; ansible-lint in CI.
- [ ] **3.6 Optional experiments.** OpenTofu for VPS + DNS; nginx vs Caddy benchmark post;
  CDN before/after measurement post (Bunny pull zone or Cloudflare proxy in front of Caddy;
  HTTPS DNS record with `alpn="h3,h2"`).
