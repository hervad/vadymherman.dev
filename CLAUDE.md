# CLAUDE.md

Personal website + blog for Vadym "Kai" Herman (GitHub: hervad). Hugo static site, self-hosted on an
AlmaLinux 10 VPS behind Caddy, provisioned with Ansible, deployed by GitHub Actions.
The repo itself is a DevOps/SRE portfolio piece, so the infrastructure matters as much as the site.

Big picture: @docs/architecture.md
Work plan and progress: @docs/roadmap.md

## How to work with Kai

- **Teach as you go.** Before writing code, explain in 2–5 sentences what you're about to do and why.
  When a concept is new, add a short everyday analogy (e.g. "a symlink switch is like changing the
  sign on a shop door: the new shop is fully stocked before anyone walks in").
- **Ask when unsure, don't guess.** Offer 2–3 concrete options, each with a one-line analogy and your
  recommendation. One question at a time unless they're tightly related.
- **One roadmap step per session.** Work in small, reviewable diffs. Don't start the next step unprompted.
- **Evidence over confidence.** Run the command and show the output instead of claiming something works.
  If something you said earlier was wrong, say so explicitly and correct it.
- **After each step**, add the concepts you explained to docs/learning-log.md (1–3 lines each). These
  become blog post material later.

## Commands

- `make tools`: install the pinned Hugo into ./.bin (versions in versions.env)
- `make serve`: local preview with drafts at http://localhost:1313
- `make check`: strict build (warnings fail) + i18n key check + page sizes. Run before saying "done".
- `make ansible-check`: dry run of the server playbook (asks permission; touches a real server)
- Custom commands: /next, /explain, /review, /checkpoint, /new-post, /decision

## Hard rules

- Hugo version is pinned in versions.env. Always use `./.bin/hugo` (via make), never a system hugo.
  Use current Hugo APIs: config key `label` (not `languageName`), `hugo.Data` (not `.Site.Data`),
  partials live in `layouts/_partials/`. `make check` fails on any deprecation warning, but some
  deprecations exist only in the docs and never warn (e.g. `site.Language.Lang`): on every Hugo
  upgrade, read the release notes for each version skipped and grep layouts/ for what they mention.
- **No npm, no node_modules, no frameworks, no CDNs, no web fonts, no third-party scripts** without
  asking first. Exceptions already approved for later steps: Pagefind (2.4), giscus (2.5),
  GoatCounter (2.6), each loaded only on demand.
- Page budget: ≤ 30 KB compressed HTML+CSS per page, 0 KB JavaScript on initial load except tiny
  inline snippets (theme init). CSS stays inlined while under ~14 KB.
- Every user-facing string goes through `{{ i18n "key" }}` with the key added to **both**
  i18n/en.toml and i18n/pl.toml.
- Content rules: @docs/content-guide.md. Don't write Kai's posts or About page for him; suggest
  structure and edit his drafts.
- Infrastructure: Ansible must stay idempotent (2nd run = changed=0). SELinux stays enforcing; fix
  labels, never disable it. Never run playbooks, ssh, rsync or git push without asking.
- Secrets: never read, print or commit them. Ansible secrets only via ansible-vault (*.vault.yml).
- Non-trivial technical choices get an ADR in docs/decisions/ (use /decision).

## Pending work markers

Pending items are marked `TODO(<roadmap step>)` in code and config; search for `TODO(` to find them.
Domain: vadymherman.dev (vadymherman.com redirects to it from step 1.3). VPS: 192.99.43.201.

## Definition of done (every step)

1. `make check` passes with no warnings.
2. You showed the relevant output (build output, curl response, playbook recap).
3. docs/roadmap.md checkbox ticked; learning-log updated; ADR written if a decision was made.
4. Suggested a Conventional Commit message (feat:, fix:, docs:, infra:, ci:, chore:).
