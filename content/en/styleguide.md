---
title: "Styleguide"
description: "Every element of the Signal design on one page. Switch the theme to check both. Draft: never published."
draft: true            # visible in `make serve` only; never built for production, not in the sitemap
layout: styleguide
eyebrow: "Design system · step 1.2"
demo:
  projectsTitle: "Rows: projects"
  projects:
    - { title: "vadymherman.dev", status: "live", desc: "This site. Hugo, Caddy on AlmaLinux 10, Ansible, GitHub Actions." }
    - { title: "Ansible hardening roles", status: "in progress", desc: "base, users_ssh, firewall, SELinux, Caddy. Second run: changed=0." }
    - { title: "Monitoring node", status: "planned", desc: "Uptime Kuma on rootless Podman with Quadlet, public status page." }
  postsTitle: "Rows: posts"
  posts:
    - { date: "2026-10-09", title: "Turning off SSH passwords the day the server went online" }
    - { date: "2026-10-08", title: "Pinning checksums for build tools" }
    - { date: "2026-10-07", title: "Hello, world" }
  proseTitle: "Prose (Markdown)"
---

## Heading level 2

### Heading level 3

A paragraph with **bold**, *italic*, a [link inside text](/en/), and `inline code`. Body text is
Geist at 17 px with a line length of about 66 characters, so long technical posts stay readable.
Polish and Ukrainian get automatic hyphenation.

> A blockquote: muted text behind an accent rule. Use it for quoting logs, docs or people.

- An unordered list item
- Another item with `code`
  - A nested item

1. Ordered step one
2. Ordered step two

---

| Setting | Value | Why |
|---|:---:|---:|
| `PasswordAuthentication` | no | first value wins |
| `PermitRootLogin` | prohibit-password | step 1.3 sets it to no |
| A long cell that makes this table wider than a phone screen, to prove it scrolls | — | 30 rem |

```bash {title="scripts/fetch-fonts.sh"}
# comment: verify every committed font file
for f in static/fonts/*.woff2; do
  sha256sum "$f"   # prints "<hash>  <file>"
done
echo "fonts OK"
```

```console
$ make check
i18n OK: 20 keys in en, pl, uk
```

```yaml {title="group_vars/all.yml"}
site_domain: vadymherman.dev   # string
site_root: /srv/site
timezone: Europe/Warsaw
```

```
A line without a language and without a title gets no title bar. This one is deliberately very long so it has to scroll sideways instead of wrapping onto the next line.
```
