---
description: Review uncommitted changes against the project rules before committing
---
Review the current uncommitted changes (`git diff` and untracked files) against CLAUDE.md.

Check and report pass/fail for each:
1. `make check` passes with no warnings (run it, show the summary).
2. No new JavaScript, npm packages, external requests, fonts or CDNs beyond what's approved.
3. Every new UI string uses i18n and exists in both i18n/en.toml and i18n/pl.toml.
4. Page size: biggest HTML pages from `make check` output, compared with the 30 KB budget.
5. Accessibility basics: alt text, heading order, link text, focus styles not removed.
6. Ansible changes (if any): idempotent, no hard-coded secrets, SELinux untouched or fixed properly.
7. No secrets, IPs or personal data accidentally added.

Then list concrete fixes (file + line) and propose a Conventional Commit message. Don't commit.
