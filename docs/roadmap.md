# Roadmap

One step per session. `/next` picks the first unchecked step. Each step lists what it delivers,
what you learn, and how we know it's done. Steps marked **(you)** are things only you can do
(payments, accounts); Claude prepares a checklist and waits. Texts: Claude may write them, you
review and approve before publishing.

"Research fixes" sub-bullets come from docs/research/2026-10-stack-review.md (details and sources there).

## Phase 0: Set up the workshop

- [x] **0.1 Orientation.** `make tools` and `make check` pass on Fedora; `git init`, first commit.
  Claude walks through the repo layout and how a Markdown file becomes an HTML page.
  - Learn: Hugo's build pipeline (content → templates → public/), why tool versions are pinned.
  - Done when: `make serve` shows the site at localhost:1313 and you can explain the folders.
  - Research fixes: retag inventory IP `TODO(0.3)`; replace deprecated `site.Language.Lang` in
    baseof.html (no build warning for it); verify Hugo/Pagefind checksums in install-tools.sh.
- [x] **0.2 GitHub repo + CI. (you + Claude)** Create the GitHub repo, push, CI goes green.
  - Learn: what GitHub Actions does on each push; reading a workflow file.
  - Done when: the CI badge is green and the `public` artifact downloads.
  - Research fixes: actions v4 → current, pinned by commit SHA; `persist-credentials: false`;
    pin `ubuntu-24.04`; `timeout-minutes`; add `.github/dependabot.yml` for github-actions.
    Unverified (found in 0.1): `cat versions.env >> "$GITHUB_ENV"` may reject the `#` comment
    lines; if the first run fails there, append only `NAME=value` lines.
- [x] **0.3 Domain + VPS. (you)** Register the domain (Cloudflare Registrar, .dev), order the VPS
  (OVHcloud VPS-1, Beauharnois per ADR 0008, AlmaLinux 10), add your SSH key. Claude then replaces every placeholder.
  - Learn: DNS records (A, AAAA, CAA), what a registrar vs a DNS host does.
  - Done when: `ssh` works with your key, `dig +short yourdomain` returns the VPS IP, no
    `example.dev` left in the repo.

## Phase 1: MVP (target: one weekend per 2–3 steps)

- [x] **1.1 How the templates work.** Guided tour of layouts/: baseof + blocks, partials, lookup
  order, `.Pages` vs `site.RegularPages`. Small exercise: add reading time to posts.
  - Done when: Claude made the change and you can explain how it works (what each line does and
    why).
- [x] **1.2 Design.** Follow docs/design-brief.md: Claude proposes a design plan (palette, type
  scale, layout wireframe), you pick, then it's implemented in main.css. Add a no-flash dark/light
  toggle and a /styleguide/ page (draft, not in nav) showing every element in both themes.
  - Done when: Lighthouse accessibility 100, both themes checked, CSS < 14 KB.
  - Design decided 2026-10-08 (Signal): build from docs/design-spec.md; lab in docs/design/.
    Needs an ADR (0009: self-hosted Geist, Geist Mono, JetBrains Mono) before adding fonts.
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
  - Carried over from 0.3: bring the hand-made `/etc/ssh/sshd_config.d/01-no-passwords.conf`
    under users_ssh (drop-ins are read alphabetically, first value wins; `50-cloud-init.conf`
    says `yes`); the first run connects as `almalinux` (`-e ansible_user=almalinux`), later runs
    as `admin`, then lock `almalinux` (it has passwordless sudo); add A/AAAA for
    vadymherman.com + www together with the redirect; CAA matching the issuer set in the
    Caddyfile; consider `timezone: UTC` (the server is in Canada, Warsaw time is misleading in logs).
  - Carried over from 1.2: long cache headers for `/fonts/` (Lighthouse flagged "Cache TTL: None"
    on the local test server). Font URLs are not fingerprinted, so a font update must change the
    URL (e.g. `/fonts/v2/`) or browsers keep the old file for the whole cache lifetime.
  - Progress (2026-10-10, stopped after piece 0 of 6): tools + lab VM done. ansible-core 2.20.7;
    collections pinned (ansible.posix 2.2.2, community.general 13.5.0, `make ansible-deps`);
    lab VM `vh-lab` on the desktop from the signature-verified AlmaLinux 10.2 cloud image
    (docs/runbooks/lab-vm.md); `inventory/local.yml`; Ansible ping → pong. Fixed: group_vars
    moved to `inventory/group_vars/all/` (playbooks never loaded it). Admin user is `kai`.
  - Piece 1 done on the lab (2026-10-10): `base` role sets hostname, UTC, chrony, packages
    (incl. policycoreutils-python-utils), dnf-automatic: security only, applied daily,
    `reboot = when-needed`. Dry run clean, real run, second run `changed=0`, verified on the VM.
    Decided: lab is the default inventory (production needs `-i`), timezone UTC.
  - Piece 2 done on the lab (2026-10-10): `users_ssh` creates kai (wheel, sudo password from
    ansible-vault `inventory/group_vars/all/secrets.vault.yml`, key from `files/kai.pub`) and
    deploy (no sudo, key in 1.4); `01-hardening.conf`: no passwords, no root, AllowUsers kai
    deploy; two-phase bootstrap (run 1 as almalinux keeps it allowed, run 2 as kai removes its
    SSH access and NOPASSWD sudo). Verified: almalinux and password logins refused, kai works,
    run 3 `changed=0`. Vault password in `infra/ansible/.vault_pass` (600, gitignored) + KeePassXC.
    Next: piece 3 = `firewall` (firewalld: ssh, http, https, http3/UDP 443).
  - Piece 3 done on the lab (2026-11-27): `firewall` installs firewalld (2.4.3 on AlmaLinux
    10.2), starts and enables it; zone `public` has `ssh`, `http`, `https`, `http3` (443/udp)
    plus the default `dhcpv6-client`; the default `cockpit` door is removed. Decided: SSH open
    to all addresses, key only (CI deploys come from changing addresses); `dhcpv6-client` stays
    until the VPS's IPv6 setup is known; no Cockpit on the VPS. Dry run on the fresh VM:
    `changed=1 skipped=3`; real run `changed=4`; second run `changed=0`. From the desktop:
    22 connects, 80 "connection refused" (open, nothing listens yet), 9090 "no route to host"
    (rejected by firewalld). Next: piece 4 = `selinux`.
  - Piece 4 done on the lab (2026-11-27): `selinux` keeps the mode enforcing (a guard; the
    image ships enforcing), records the rule `/srv/site(/.*)?` → `httpd_sys_content_t`, and
    repairs labels under the site root on every run (`restorecon`, `changed` only when a file
    was relabelled). Found by testing: a rule alone labels nothing; a new folder inherits its
    parent's label (`var_t` under `/srv`) whether made by `mkdir` or by Ansible's `file`
    module, so the first design (relabel only when the rule changes) was replaced. Tested in
    three states: no folder `ok`, wrong labels `changed`, correct labels `ok`.
    For piece 5: the caddy role runs after this role, so it must create the site folders with
    the label already set (`setype` on the `file` task); otherwise the first run on a fresh
    server leaves them `var_t` until the next run. Next: piece 5 = `caddy`.
  - Piece 5 done on the lab (2026-11-27): `caddy` enables the `@caddy/caddy` COPR (chroot set
    to `epel-10-x86_64`; the module's own guess `almalinux-10.2` gets a 404 from COPR), installs
    Caddy 2.11.9, creates `site_root/releases/placeholder/en/` with the web-content label at
    creation, points `current` at it only when no `current` exists, writes the Caddyfile through
    `caddy validate`, reloads on change, starts and enables the service. Lab certificates come
    from Caddy's private authority (`caddy_tls_internal`, ADR 0011); updates are by hand
    (`-e caddy_upgrade=true`). Tested from the desktop with `curl --resolve`: 308 from HTTP,
    302 `/` → `/en/`, 200 over HTTP/2 and HTTP/3, 301 from www and both .com names, own 404
    page, security headers everywhere, `no-cache` for pages, one year for `/fonts/`. Caddy runs
    confined (`httpd_t`). Final run `changed=0`. Found by testing: the default cache rule does
    not reach error responses (repeated in `handle_errors`); `caddy validate` as root created
    a private authority in `/root` (now sent to `/run` with `XDG_DATA_HOME`). Access log goes
    to the journal (`TODO(2.6)`). `community.general` bumped to 14.0.1 (changelog read, lab dry
    run `changed=0`). Next: piece 6 = the real VPS.
  - For piece 6: add the DNS records for `www` and both `.com` names before the first run on
    the VPS (Caddy asks for a certificate per name and retries on failure); choose the issuer
    and add the matching CAA record; check on the lab whether `dnf-automatic` really skips COPR
    packages; the Caddy tasks' dry-run path on a server without Caddy (`stat` guard) was written
    but not exercised, the lab needs a reset for that.
  - Open issues: lab IP comes from DHCP (may change after a reset); lab reset is documented,
    not scripted; the VPS gets `base` only in piece 6. The firewall role assumes the default
    zone is `public` and does not set it: check `firewall-cmd --get-default-zone` on the VPS
    in piece 6.
  - Refresh 2026-11-27: `ansible.cfg` now sets `inject_facts_as_vars = False`; the lab dry run
    the same day passed (`ok=16 changed=0 failed=0`). DNSSEC was enabled in Cloudflare on
    2026-11-27 and the DS record is pending (up to two days; check `dig +short DS vadymherman.dev`).
    Still no CAA or AAAA record.
    Done in piece 5: the COPR gives EL10 Caddy 2.11.9 (same as upstream); community.general is
    pinned at 14.0.1.
  - Practices review 2026-11-27 (docs/research/2026-11-practices-review.md): in the caddy role,
    use `caddy validate` as the template task's `validate:` (same pattern as `sshd -t`); at the
    wrap-up, add a `verify.yml` with asserts and script the lab reset.
- [ ] **1.4 Deploy pipeline.** Deploy job in GitHub Actions: build → precompress (brotli, gzip) →
  rsync to releases/<sha>/ → atomic symlink switch → smoke test (build SHA meta tag) → keep last 5
  releases. Separate manual "rollback" workflow. Restricted deploy key (rrsync), pinned host key.
  - Learn: atomic renames, why symlink switching avoids half-deployed sites, least privilege.
  - Done when: a push to main is live in < 2 min, and a rollback is tested once.
  - Research fixes: forced-command wrapper for `activate <sha>` (rrsync can't flip symlinks;
    `mv -Tf` a temp link); reconcile deploy permissions with inventory/group_vars/all/vars.yml (deploy_user);
    `rsync -c --link-dest`; protected `production` environment, `cancel-in-progress: false`.
  - Refresh 2026-11-27: rrsync is its own package, `rsync-rrsync` (`/usr/bin/rrsync` on
    Fedora 44); confirm on the lab with `rpm -ql rsync-rrsync` before writing the forced command.
  - Practices review 2026-11-27, before the deploy job exists: a `make lint` target and CI job
    (shellcheck, ansible-lint with the `production` profile, zizmor, and a guard that every
    `*.vault.yml` starts with `$ANSIBLE_VAULT`), tools pinned as in ADR 0006. **(you)** push the
    local commits; add a ruleset on `main` with required checks, turn on `sha_pinning_required`
    and Dependabot alerts (cost: every change then goes through a pull request). gitleaks as a
    local hook once the deploy key exists.
- [ ] **1.5 Real content. (Claude writes, you review and approve)** Home intro, About, hand-written Projects page
  (3–5 projects: problem → approach → result), first real post. Delete hello-world.
  - Practices review 2026-11-27: turn content-guide rules into checks (allowed tags, description
    length, code blocks without a language) instead of relying on review.
- [ ] **1.6 Security headers + SEO.** CSP (hashes for inline scripts), HSTS, Open Graph/Twitter
  meta, JSON-LD (Person, BlogPosting), sitemap check, robots.txt.
  - Done when: MDN HTTP Observatory A+, SSL Labs A+, Lighthouse 100 on all four categories.
  - Research fixes: RSS limited to `blog` (About shows up dated 0001); `Sitemap:` in robots.txt;
    own JSON-LD partial (Hugo's is microdata); feed link on all pages; CSP with script **and**
    style hashes; CORP + `frame-ancestors`; no COEP (breaks giscus); no HSTS `preload` (.dev is
    preloaded).
- [ ] **1.7 Launch.** Launch checklist (links, 404, RSS validates, mobile check), announce.
  Write the first ADR-based post: "Why Hugo + Caddy + AlmaLinux".
  - Decide before launch (open since 2026-11-27): Hugo `timeZone`. Unset, a post dated
    `2026-10-07` is published at 00:00 UTC; with `timeZone = "Europe/Warsaw"` the feed's
    `pubDate` becomes 00:00 +0200. Visible dates don't change. Cheap to choose now, awkward
    after feed readers have seen the old timestamps.
  - Nice-to-have: speculation rules (prefetch on hover); view transitions under
    `prefers-reduced-motion: no-preference`.

## Phase 2: Features

- [ ] **2.1 Ukrainian and Polish versions.** Enable `uk` and `pl` in hugo.toml (English stays the
  default, ADR 0010), hreflang + x-default, language switcher that never 404s, untranslated-post
  handling, RSS per language. Claude translates Home + About, you review.
  - Before enabling `uk`: add the Cyrillic font subsets (cyrillic + cyrillic-ext) to
    fetch-fonts.sh and fonts.css, measured and pinned like ADR 0009; until then Cyrillic text
    falls back to the system font (seen in a test build on 2026-10-10).
- [ ] **2.2 GitHub projects data.** scripts/fetch_github.py (build-time, GITHUB_TOKEN, fail-soft)
  → data/github/repos.json; data/projects.yaml for curated EN/PL blurbs; daily scheduled build.
  - Refresh 2026-11-27: GitHub disables scheduled workflows in a public repo after 60 days
    without repository activity; plan a keep-alive or accept re-enabling by hand.
- [ ] **2.3 Images.** Markdown image render hook: AVIF/WebP/JPEG `<picture>`, srcset, width/height,
  lazy loading. Auto-generated Open Graph images per post.
- [ ] **2.4 Search.** Pagefind index after build, loaded only when the search box is focused or `/`
  is pressed; per-language results.
  - Refresh 2026-11-27: pinned at 1.6.0 (no breaking changes from 1.5.2); read the release
    notes of the then-current version before building.
- [ ] **2.5 Comments.** giscus via GitHub Discussions, injected only when scrolled near or clicked;
  `comments: false` front matter switch. Plus a "reply by email" link (0 KB).
  - To verify before building (not checked yet): giscus maintenance status.
- [ ] **2.6 Analytics.** GoatCounter as a systemd service (new Ansible role) behind Caddy on
  stats.<domain>; cookieless; privacy page EN/PL; GoAccess report from Caddy logs.
  - To verify before writing the privacy page (not checked yet): PKE art. 399 and UKE guidance,
    from a primary source.
- [ ] **2.7 CI quality gates.** HTML validation, lychee link checks (internal on PRs, external
  weekly), Lighthouse CI with byte budgets. `make check` reports gzip/brotli sizes, not raw bytes.
  - Practices review 2026-11-27: a `make outdated` target plus a weekly scheduled run (pinned
    tools and collections against their latest releases); pin the HTML validator jar by hash.
    Done early: `make check` now fails on a missing i18n key (`--printI18nWarnings`).

## Phase 3: SRE polish

- [ ] **3.1 Monitoring node.** Second small VPS: Uptime Kuma (rootless Podman + Quadlet), public
  status page, TLS-expiry and downtime alerts.
- [ ] **3.2 Metrics.** Caddy metrics + node_exporter → Prometheus/Grafana (or Grafana Cloud free).
  - Refresh 2026-11-27: enable metrics with Caddy's global `metrics` option (the documented form).
- [ ] **3.3 Backups.** restic for /etc, Caddy data, GoatCounter DB; restore tested and documented.
- [ ] **3.4 SLOs + runbooks.** docs/slo.md (99.9 %, p95 TTFB), runbooks: site down, cert failure,
  disk full, rollback.
- [ ] **3.5 Hardening extras.** CrowdSec with the Caddy collection; Molecule tests; ansible-lint in CI.
  - Practices review 2026-11-27: ansible-lint is proposed to move forward to before 1.4 (see there).
- [ ] **3.6 Optional experiments.** OpenTofu for VPS + DNS; nginx vs Caddy benchmark post;
  CDN before/after measurement post (Bunny pull zone or Cloudflare proxy in front of Caddy;
  HTTPS DNS record with `alpn="h3,h2"`).
