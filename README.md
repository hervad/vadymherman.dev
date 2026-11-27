# Personal site

[![CI](https://github.com/hervad/vadymherman.dev/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/hervad/vadymherman.dev/actions/workflows/ci.yml)

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

## Upgrading tools

Hugo and Pagefind are pinned in `versions.env`: a version plus the SHA-256 of each download.

1. On a branch, read the release notes of every version skipped, then change the version in
   `versions.env`.
2. `make tool-hashes` prints the new SHA-256 lines; paste them into `versions.env`.
3. `make tools` installs the new binary and refuses it if the hash differs.
4. `make check` builds with `--panicOnWarning`, so a deprecation reported by the new version
   fails the build instead of scrolling past.
5. Review the diff and merge.

## Status

Work is tracked in [docs/roadmap.md](docs/roadmap.md).

## License

Code (templates, CSS, scripts, Ansible, CI) is [MIT](LICENSE). Writing under `content/` is
[CC BY 4.0](LICENSE-CONTENT): reuse it freely, with credit and a link.
