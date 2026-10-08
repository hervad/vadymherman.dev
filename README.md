# Personal site

Source for my personal website and blog: a Hugo static site, self-hosted on an AlmaLinux 10 VPS
behind Caddy, provisioned with Ansible and deployed by GitHub Actions.

The site is intentionally small (target: < 30 KB per page, no JavaScript on load) and the
infrastructure is part of the portfolio: see [docs/architecture.md](docs/architecture.md) and the
decision records in [docs/decisions/](docs/decisions/).

## Quick start

```bash
make tools   # install the pinned Hugo into ./.bin
make serve   # http://localhost:1313
make check   # strict build, the same one CI runs
```

## Status

Work is tracked in [docs/roadmap.md](docs/roadmap.md).
