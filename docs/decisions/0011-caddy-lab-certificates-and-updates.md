# 0011. Caddy: lab certificates from a private authority, updates by hand

- Status: accepted
- Date: 2026-11-27

## Context
Two things came up when the `caddy` role was written (roadmap 1.3, piece 5).

1. Every role is proven on the lab VM before it touches the VPS, but Let's Encrypt issues a
   certificate only after reaching the server under its public name. The lab sits on a private
   address (192.168.122.x), so the production way of getting a certificate cannot work there.
2. Caddy comes from the `@caddy/caddy` COPR (ADR 0002). COPR publishes no security advisory
   data, and `dnf-automatic` runs in security-only mode (base role), so it is not expected to
   update Caddy. (That expectation is from the October stack review and is not yet verified on
   the lab.)

## Options considered
Lab certificates:
1. **Caddy's own private authority on the lab** (`local_certs`), switched by one inventory
   variable. HTTPS, HTTP/2, HTTP/3, redirects and headers are all tested on the lab. Cost: one
   conditional in the Caddyfile template; tests need the lab's root certificate and
   `curl --resolve`.
2. **Plain HTTP on the lab.** Simplest template, but TLS, the HTTP→HTTPS redirect, HSTS and
   HTTP/3 would be tested for the first time on the real server.
3. **A real certificate through a DNS challenge.** Closest to production, but needs a Cloudflare
   API token on the server and a Caddy build with a plugin, so not the COPR package.

Updates:
1. **By hand, on purpose.** The role installs with `state: present`; an upgrade is a run with
   `-e caddy_upgrade=true`, lab first. Cost: a security fix waits until someone acts, and lab and
   VPS can run different versions if installed weeks apart.
2. **A weekly timer that upgrades only Caddy.** Fixes arrive unattended, but a new version
   restarts the web server with nobody watching, and there is no monitoring before step 3.1.
3. **Pin an exact version.** Every upgrade is a reviewable diff, but COPR may remove superseded
   builds (not verified), which would break a fresh install.

## Decision
Lab certificates: option 1. `caddy_tls_internal: true` is set only in `inventory/local.yml`; the
template then writes `local_certs` and `skip_install_trust` instead of the `email` line. The lab
keeps the real site name, so lab and production differ in that one block.

Updates: option 1 for now, to be revisited when `make outdated` exists (roadmap 2.7) and again
when monitoring exists (3.1).

## Consequences
- Tested on the lab on 2026-11-27 with Caddy 2.11.9: 308 from HTTP, 302 from `/` to `/en/`, 200
  over HTTP/2 and over HTTP/3, 301 from the three redirect names, the site's own 404 page with
  status 404, security headers on every response, cache rules as written.
- What the lab cannot test: getting a certificate from a public authority, the CAA record, and
  certificate renewal. Those are first seen on the VPS (piece 6); the issuer is chosen there.
- An upgrade restarts Caddy by itself: the package's script marks `caddy.service` for restart
  (`rpm -q --scripts caddy`). No restart handler in the role.
- Until 2.7, checking for a new Caddy release is a manual habit. Upstream releases:
  https://github.com/caddyserver/caddy/releases
- Related choice made in the same piece: the access log goes to the systemd journal, not to a
  file under `/var/log/caddy` (the package does not create that folder, and whether SELinux lets
  Caddy rotate its own log files was not verified). Marked `TODO(2.6)` in the Caddyfile template.
