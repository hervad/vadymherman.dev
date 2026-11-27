# Repo tooling gap review: vadymherman.dev

Date of all lookups: 2026-11-27. Read-only research; nothing installed, no repo file edited,
no server contacted, no playbook run.

Evidence labels used below:

- **[repo file]** read from the working tree
- **[local run]** command run on the dev machine, read-only (shellcheck, `hugo --renderToMemory`, `dnf5 repoquery`, reading installed Ansible source)
- **[gh api]** GitHub REST API via `gh` (higher confidence)
- **[web claim]** general knowledge or docs I did not re-check today (lower confidence; verify in a browser)
- **[could not verify]** not tested, with the reason

Raw release/licence table: `gh-facts.tsv` in this folder (output of `gh api repos/<r>` + `releases/latest`).

---

## 1. What the repo already does well (so it is not re-recommended)

| Practice | Evidence |
|---|---|
| Actions pinned by full SHA with version comment; SHAs match the tags | [repo file] ci.yml; [local run] `git ls-remote` : checkout `3d3c42e…` = `refs/tags/v7.0.1`, upload-artifact `cf430e0…` = `refs/tags/v7.0.2`; both are the latest releases [gh api] |
| Least privilege in CI | [repo file] `permissions: contents: read`, `persist-credentials: false`, `timeout-minutes`, pinned `ubuntu-24.04`, concurrency group. [gh api] repo default workflow permissions = `read`, `can_approve_pull_request_reviews: false` |
| Tool pinning with SHA-256 (ADR 0006) | [repo file] versions.env, install-tools.sh, fetch-fonts.sh. Hugo 0.170.1 and Pagefind 1.6.0 are the current latest releases [gh api] |
| Dependabot for github-actions, weekly | [repo file]; [gh api] "Dependabot Updates" ran weekly 2026-10-15 … 2026-11-26, all success; 0 PRs because both actions are already at latest |
| Secret scanning + push protection | [gh api] `secret_scanning: enabled`, `secret_scanning_push_protection: enabled` |
| .editorconfig | [repo file] present (utf-8, LF, final newline, 2 spaces, tabs in Makefile) |
| Ansible collections pinned exactly | [repo file] requirements.yml `==2.2.2`, `==13.5.0` |
| Vault for secrets, password file gitignored, `no_log` on the password task, `validate: sshd -t` on the sshd template | [repo file] |
| shellcheck-clean scripts | [local run] `shellcheck scripts/*.sh` exit 0 with ShellCheck 0.11.0 (3 scripts, 138 lines) |
| ADRs, runbooks dir, roadmap, CI badge, two licences | [repo file] |

## 2. Gaps found (facts first, tools second)

1. **Nothing lints or tests `infra/ansible` anywhere.** `make ansible-lint` exists in the Makefile but
   `ansible-lint` is not installed on the dev machine [local run: `command -v ansible-lint` empty], there is
   no `.ansible-lint` config, and ci.yml only runs `make check` (Hugo). ansible-lint in CI is planned for
   step 3.5, i.e. after all five roles have been written. START-HERE.md line 19 already tells the reader
   to `dnf install ansible-lint`.
2. **shellcheck is not wired in.** Scripts pass today, but neither `make check` nor CI runs it, so the
   clean state is not protected.
3. **Nothing lints the workflow files.** One workflow today; step 1.4 adds deploy + rollback workflows that
   hold an SSH deploy key. That is where workflow mistakes get expensive.
4. **`main` is unprotected.** [gh api] `GET /repos/…/rulesets` = `[]`; `GET …/branches/main/protection` = 404
   "Branch not protected". Force-push and branch deletion are possible; from step 1.4 a push to main is a
   production deploy.
5. **Repo settings that cost nothing are off.** [gh api] Actions: `allowed_actions: all`,
   `sha_pinning_required: false`. Dependabot alerts: `GET …/vulnerability-alerts` = 404 (disabled).
   `dependabot_security_updates: disabled`. `secret_scanning_non_provider_patterns: disabled`
   (that is the group that covers generic secrets such as private keys [web claim]; availability on a
   free public repo [could not verify]). Community profile 42 % (licence + readme only; no SECURITY.md).
6. **A missing i18n key used in a template builds clean.** [local run] In a scratch copy of the site I
   added `{{ i18n "probeMissingKey" }}` to footer.html (key in no i18n file):
   - `hugo --renderToMemory --panicOnWarning` → exit 0, no output (silent empty string)
   - same plus `--printI18nWarnings` → `WARN i18n|MISSING_TRANSLATION|en|probeMissingKey`, exit 1
   `scripts/check-i18n.py` compares the i18n files with each other, so it cannot see a key that is in
   none of them. CLAUDE.md's hard rule ("every user-facing string goes through i18n with the key in every
   file") is therefore only half enforced.
7. **Nothing guards against committing a decrypted vault file.** `inventory/group_vars/all/secrets.vault.yml`
   is tracked. If `ansible-vault edit/decrypt` leaves it in plaintext and it is committed, neither GitHub
   push protection (provider token patterns) nor a generic scanner is guaranteed to notice a home-made
   password. A two-line check (`head -c 14` of every `*.vault.yml` must be `$ANSIBLE_VAULT`) closes this.
   I did not open the vault file (per instructions), so its current state is [could not verify].
8. **Pins that no bot watches.** versions.env (Hugo, Pagefind), requirements.yml (collections), the font
   URLs, the AlmaLinux cloud image. [gh api] community.general has tags 13.5.1 and 14.0.x while the repo
   pins 13.5.0 (pinned ~7 weeks ago). Dependabot has no ansible-galaxy ecosystem
   [gh api: directory list of dependabot/dependabot-core has no ansible entry].
9. **ADR 0006 open question can be closed.** [gh api] `GET /repos/gohugoio/hugo/attestations/sha256:<pinned amd64 hash>`
   = 404, same for the pinned Pagefind hash; the Hugo release has `checksums.txt` but no `.sig`/`.pem`/
   provenance asset, Pagefind has none either. So there is nothing stronger than the pinned hash to verify
   today.
10. **Local/CI tool drift outside versions.env.** [gh api: actions/runner-images Ubuntu2404-Readme.md] the
    runner ships shellcheck 0.9.0, yamllint 1.38.0, "Ansible 2.21.6", Podman 4.9.3; the dev machine has
    ShellCheck 0.11.0 and ansible-core 2.20.7. Any linter used from the runner image breaks the repo's
    own "same binary on laptop and CI" rule.
11. **Work not yet off the machine.** [local run] `git log origin/main..HEAD` = 5 commits (all of step 1.3
    so far), last CI run on main 2026-10-09 [gh api]. Not a tooling gap, but the Ansible work has never
    been through CI or had a second copy. (Pushing is Kai's call.)
12. **`--printUnusedTemplates` finding.** [local run] production-style build warns:
    `Template /_markup/render-table.html is unused` and `Template /styleguide.html is unused`. With
    `--buildDrafts` both warnings disappear (styleguide page is a draft; the gnome draft post has a table).
    So: no dead templates, but the flag cannot be added to the strict non-draft build as is.

## 3. Candidates

Format: catches / npm-free + pinnable / version + maintenance [gh api unless noted] / cost / verdict.

### 3.1 Hooks runner: pre-commit framework vs prek vs lefthook vs plain hook + make target

- pre-commit https://github.com/pre-commit/pre-commit : v4.7.0 (2026-10-13), MIT, not archived, Fedora
  package `pre-commit 4.7.0` [local run: dnf5 repoquery]. Python, no npm itself, but remote hooks build
  their own environments (node-based hooks silently bring Node; Go hooks need a Go toolchain) and hook
  `rev:` is a tag unless frozen to a SHA. Dependabot has a `pre_commit` ecosystem directory [gh api].
- prek https://github.com/j178/prek : v0.5.12 (2026-11-26), MIT, Rust single binary with `.sha256`
  assets; reads the same config. Pre-1.0, releases every few days.
- lefthook https://github.com/evilmartians/lefthook : v2.2.4 (2026-11-26), MIT, Go binary + checksums.
- Plain: `make lint` as the single entry point, CI runs the same target, optional 5-line
  `.githooks/pre-commit` enabled with `git config core.hooksPath .githooks`.
- Cost of a framework here: a second pinning mechanism next to versions.env (ADR 0006 says one), and a
  second "what runs the checks" answer next to the Makefile.
- **Verdict: skip the frameworks; adopt `make lint` + CI job now, thin git hook optional.** Reason: the
  Makefile is already the documented entry point and CI is the gate; a hook only saves a round trip.
  Worse: no staged-files-only speed-up, the hook is opt-in per clone, and a reviewer scanning for
  `.pre-commit-config.yaml` will not find one. If a framework is wanted later, use `repo: local` +
  `language: system` hooks so it downloads nothing.

### 3.2 shellcheck

- Catches: quoting, unset variables, non-portable constructs in bash.
- https://github.com/koalaman/shellcheck : v0.11.0 (2025-08-04), GPL-3.0, active (last commit 2026-11-27).
  Static Linux tarballs in the release, no checksum file, but the API exposes
  `digest: sha256:b7af85e4…` for `shellcheck-v0.11.0.linux.x86_64.tar.gz`. Fedora `ShellCheck 0.11.0`
  (installed). Runner image has 0.9.0.
- Cost: zero findings today; near-zero noise on 138 lines.
- **Verdict: adopt now** in `make lint`. Decide once: either pin it in versions.env like Hugo (consistent
  with ADR 0006, two more hash lines) or accept the runner's 0.9.0 (zero upkeep, but laptop and CI can
  disagree). I would pin.

### 3.3 shfmt

- Catches: formatting drift in shell. https://github.com/mvdan/sh : v3.14.1 (2026-09-06), BSD-3, active;
  raw binary asset, digest via API. Fedora has only `shfmt 3.7.0-5.fc41` (old build) [local run].
- **Verdict: skip.** Three scripts, one author, .editorconfig already there. Revisit if scripts/ passes
  ~10 files.

### 3.4 Workflow linting: zizmor vs actionlint

- zizmor https://github.com/zizmorcore/zizmor : v1.33.1 (2026-11-22), MIT, very active. Security audits:
  `unpinned-uses`, `excessive-permissions`, `template-injection`, `artipacked`, `dangerous-triggers`,
  `secrets-outside-env`, `ref-version-mismatch`, `impostor-commit`, `known-vulnerable-actions`,
  `dependabot-cooldown`, `unpinned-tools`, … (42 audits listed in docs/audits.md [gh api]). Rust binary
  in releases (no checksum file; API digest `sha256:3e6a301c…` for x86_64-linux-gnu), also PyPI, crates,
  ghcr image, and `zizmorcore/zizmor-action` v0.9.2 (2026-11-24; README says incompatible changes
  possible until stable). Not in Fedora 44 repos [local run]. Works offline for most audits.
- actionlint https://github.com/rhysd/actionlint : v1.7.12 (2026-03-30), MIT, not archived, but the last
  commit on the default branch is 2026-04-19 [gh api] (7 months quiet). Catches syntax, expression types,
  unknown inputs, and runs shellcheck on `run:` blocks. Binary + checksums.txt. Not on the runner image,
  not in Fedora 44.
- Overlap is small, but the repo has one workflow and the VS Code GitHub Actions extension (already in
  .vscode/extensions.json) covers syntax in the editor; a syntax error also shows on the first run.
- **Verdict: zizmor, adopt now (must be green before the deploy workflow of step 1.4 is written).
  actionlint: skip**, and keep deploy logic in `scripts/*.sh` so shellcheck covers it instead of inline
  `run:` shell. Expected first findings [could not verify, not run]: `dependabot-cooldown` (no `cooldown:`
  in dependabot.yml) and possibly `unpinned-tools`/pedantic-level items.
  Worse: zizmor moves fast (a release most weeks), so a pinned binary ages quickly and new versions add
  audits that can turn a green lint red on a bump.

### 3.5 yamllint

- https://github.com/adrienverge/yamllint : v1.38.0 (2026-01-13), GPL-3.0; Fedora `yamllint 1.38.0`.
- ansible-lint depends on it and runs it as its `yaml` rule ([gh api] pyproject `yamllint>=1.38.0`;
  [local run] Fedora `python3-ansible-lint` requires `yamllint >= 1.38`).
- **Verdict: skip as a separate tool.** ansible-lint covers infra/ansible, zizmor/GitHub parse the workflows.

### 3.6 ansible-lint

- Catches: non-idempotent `command`/`shell`, missing modes, non-FQCN modules, risky permissions, bad
  Jinja spacing, deprecated syntax, plus `ansible-playbook --syntax-check`.
- https://github.com/ansible/ansible-lint : v26.11.1 (2026-11-25), GPL-3.0, active. Needs
  `ansible-core>=2.16.19` (repo has 2.20.7). Fedora `python3-ansible-lint 26.4.0` (updates) [local run].
  The repo is also a composite action (inputs `working_directory`, `requirements_file`, `args`) that can
  be SHA-pinned and tracked by Dependabot.
- Profiles (cumulative): min → basic → moderate → safety → shared → production [gh api docs/profiles.md].
  `production` adds `fqcn`, `sanity`, etc. The two written roles already use FQCN, named tasks, explicit
  modes and `no_log`, so start at `production` and record any skip with a reason; dropping to `safety`
  is the fallback if `shared`-level meta/galaxy rules prove noisy for a non-collection repo
  [could not verify, not run].
- Where: `make lint` locally (the already recommended redhat.ansible VS Code extension uses the same
  binary) and a CI `lint` job. Not in a commit hook (seconds, not milliseconds).
- CI gotcha: ansible.cfg sets `vault_password_file = .vault_pass`, which does not exist in CI. Ansible
  errors globally when the only configured vault password file is missing ([local run] installed source:
  `ansible/parsing/vault/__init__.py:361` "The vault password file %s was not found" and
  `ansible/cli/__init__.py:322-325` "An invalid or missing password file will error globally if no valid
  vault secret was found"). ansible-lint honours the same settings and documents linting without real
  secrets ([gh api] docs/usage.md "Vaults"). So CI must set `ANSIBLE_VAULT_PASSWORD_FILE` to a dummy
  file. End-to-end behaviour [could not verify, not run].
- Cost: ~1 min CI (pip install), version drift between Fedora 26.4.0 and CI unless both are pinned;
  new releases add rules.
- **Verdict: adopt now (move from step 3.5 to step 1.3, before pieces 3–5 are written).** Feedback is
  worth most while the roles are being written and explained.

### 3.7 Secret scanning: GitHub built-in vs gitleaks vs betterleaks vs trufflehog

- GitHub secret scanning + push protection: already on [gh api]. Server-side, provider patterns.
- gitleaks https://github.com/gitleaks/gitleaks : v8.30.1 (2026-03-21), MIT, binary + checksums; Fedora
  `gitleaks 8.30.0`. README: "Gitleaks is feature complete… Future releases will be security patches
  only. I'm shifting my focus to Betterleaks" [gh api].
- betterleaks https://github.com/betterleaks/betterleaks : v1.10.1 (2026-11-12), MIT, repo created
  2026-02-03, checksums + sigstore bundle. Young.
- trufflehog https://github.com/trufflesecurity/trufflehog : v3.100.1, AGPL-3.0; verifies secrets by
  calling out to providers. Heavy for this repo.
- This repo's real secret risks: decrypted vault file (not detectable by pattern), `.vault_pass`
  (gitignored), a deploy private key (step 1.4; lives in GitHub secrets and ~/.ssh, not in the repo).
- **Verdict: adopt the vault-header guard now (no tool). gitleaks (Fedora package) as a local pre-commit
  hook: attach to step 1.4**, when a private key first exists near the repo. Skip betterleaks/trufflehog.
  Also try enabling `secret_scanning_non_provider_patterns` in repo settings.
  Worse: gitleaks is in maintenance mode, so its rule set will age; revisit betterleaks at step 3.5.

### 3.8 Markdown lint

- markdownlint-cli2 https://github.com/DavidAnson/markdownlint-cli2 : npm only → excluded by the repo rule.
  The VS Code extension is already recommended [repo file].
- rumdl https://github.com/rvben/rumdl : v0.3.7 (2026-11-26), MIT (Cargo.toml), Rust binary + `.sha256`;
  pre-1.0, releases almost daily.
- mdl https://github.com/markdownlint/markdownlint : Ruby gem, no GitHub releases.
- The content-guide rules that matter ("code blocks always have a language", "every image needs alt
  text") can be enforced inside Hugo with zero tools: `warnf` in `layouts/_markup/render-codeblock.html`
  when `.Type` is empty, and in the image render hook planned for 2.3 when alt is empty;
  `--panicOnWarning` then fails `make check`.
- **Verdict: skip a CLI linter.** Editor extension for style; Hugo render hooks for the two rules with
  reader impact (code-block rule at step 1.5, alt text at 2.3). Worse: docs/ Markdown stays unlinted.

### 3.9 Prose: vale, typos, codespell

- vale https://github.com/vale-cli/vale (moved from errata-ai) : v3.29.0 (2026-11-26), MIT, binary +
  checksums; styles must be vendored or `vale sync`ed (another pin). Not in Fedora 44.
- typos https://github.com/crate-ci/typos : v1.52.2 (2026-11-11), Apache-2.0, binary (API digest only).
- codespell https://github.com/codespell-project/codespell : v2.4.3 (2026-07-15), GPL-2.0; Fedora 2.4.2.
- Three content languages (en/uk/pl); these tools are English-centric. Every text is already reviewed
  line by line by Kai, and cSpell (en, pl) is in the editor.
- **Verdict: skip all three.** If spelling slips into published posts, add codespell (Fedora package)
  scoped to `content/en` at step 2.7.

### 3.10 .editorconfig / editorconfig-checker

- .editorconfig exists. editorconfig-checker https://github.com/editorconfig-checker/editorconfig-checker :
  v4.0.2 (2026-09-19), MIT.
- **Verdict: skip the checker.** Low-value findings (trailing spaces); ansible-lint's yaml rule covers
  the files where whitespace matters.

### 3.11 Renovate vs Dependabot

- Dependabot: in place; ecosystems include `github_actions` and `pre_commit`, no ansible-galaxy, nothing
  for versions.env [gh api: dependabot-core directory list]. Supports `cooldown:` ([gh api] github/docs
  `dependabot-options-reference.md` matches "cooldown" + "default-days"; zizmor docs say Dependabot's
  default cooldown is three days and recommend seven).
- Renovate https://github.com/renovatebot/renovate : 45.2.0 (2026-11-27), AGPL-3.0, several releases a
  day. Has managers `ansible-galaxy`, `github-actions`, `pre-commit`, `custom` (regex) and a
  `github-release-attachments` datasource that re-computes a pinned asset digest from checksum files or
  by downloading the asset ([gh api] lib/modules/datasource/github-release-attachments/index.ts). It
  could in principle bump versions.env version + hash and requirements.yml. versions.env keeps the
  version and two per-arch hashes on separate lines, which needs a non-trivial regex configuration:
  end-to-end [could not verify]. `minimumReleaseAge` = cooldown.
- Running it: the hosted Mend Renovate GitHub App (third party with write access to the repo)
  [web claim], or self-hosted in Actions (Node container at run time; nothing in the repo).
- Hugo cadence [gh api]: 0.163.0 (2026-06-08) → 0.170.1 (2026-11-17), roughly a minor every 2–4 weeks.
  CLAUDE.md requires reading every skipped release note and grepping layouts/ on each upgrade, so the
  bump is deliberately manual; what is missing is the *notification*.
- **Verdict: keep Dependabot, add `cooldown` (7 days); skip Renovate for now.** Instead add a tiny
  `make outdated` (reads versions.env + requirements.yml, compares with `gh api …/releases/latest` and
  Galaxy) and run it in a weekly scheduled workflow. Revisit Renovate at step 2.7 if manual bumps hurt.
  Worse: no automatic PR with new hashes, and one more home-made script to maintain.

### 3.12 OpenSSF Scorecard

- https://github.com/ossf/scorecard v5.7.0 (2026-11-19), scorecard-action v2.6.0 (2026-11-19), Apache-2.0.
- Checks [gh api docs/checks.md]: Binary-Artifacts, Branch-Protection, CI-Tests, CII-Best-Practices,
  Code-Review, Contributors, Dangerous-Workflow, Dependency-Update-Tool, Fuzzing, License, Maintained,
  Packaging, Pinned-Dependencies, SAST, SBOM, Security-Policy, Signed-Releases, Token-Permissions,
  Vulnerabilities, Webhooks.
- A solo site repo cannot score on Code-Review, Contributors, Fuzzing, Signed-Releases, Packaging,
  CII-Best-Practices; committed woff2 fonts may trip Binary-Artifacts [could not verify]. The useful
  checks (Pinned-Dependencies, Token-Permissions, Dangerous-Workflow) overlap with zizmor.
- **Verdict: skip the action and badge; optional one-off run at step 3.5 as an audit checklist.**

### 3.13 step-security/harden-runner

- https://github.com/step-security/harden-runner : v2.23.0 (2026-11-18), Apache-2.0. Runner agent that
  audits/blocks egress. README: community tier free for public repos on GitHub-hosted runners [gh api].
- The deploy job will use only GitHub-owned, SHA-pinned actions plus repo scripts, so the scenario it
  defends against (a compromised third-party action exfiltrating the deploy key) has little surface
  here. Cost: a third-party agent with sudo in the job that holds the key, run data in a vendor SaaS,
  an allow-list to maintain.
- **Verdict: skip.** Reconsider only if third-party actions enter the deploy job. Worse: no egress
  evidence if a GitHub-owned action is ever compromised.

### 3.14 Branch protection / rulesets (solo)

- Current: none [gh api]. Rulesets are free on public repos [web claim].
- Proposal: one ruleset on the default branch: block deletion, block force-push, require the `build`
  (and later `lint`) status checks, require a pull request with 0 approvals (you cannot approve your own
  PR), no bypass. Plus Actions settings: `sha_pinning_required: true` (the field exists in
  `GET /repos/…/actions/permissions` [gh api]) and allowed actions limited to GitHub-owned + an explicit
  list. Plus enable Dependabot alerts.
- Cost: every change goes branch → PR → green → merge (about a minute; Kai already works on a branch).
  0 PRs exist so far [gh api], so this is a real workflow change.
- **Verdict: adopt before step 1.4** (ideally now). Reason: from 1.4, main = production; a required
  check is what makes "CI green" a gate instead of a report. Worse: friction for one-line doc fixes, and
  an emergency fix also has to go through a PR (or a documented bypass).

### 3.15 Commit message linting

- commitlint https://github.com/conventional-changelog/commitlint v21.2.4: npm → excluded.
- committed https://github.com/crate-ci/committed v1.1.12 (2026-11-04), Apache-2.0, Rust binary, 186 stars.
- cocogitto https://github.com/cocogitto/cocogitto 7.0.0 (2026-03-04), MIT; last push 2026-04-22.
- gitlint https://github.com/jorisroovers/gitlint v0.19.1 (2023-03-10), last push 2024-07: unmaintained
  (still in Fedora).
- All 14 commit subjects already follow the convention [local run: git log]; CLAUDE.md makes Claude
  propose the message and Kai approve it.
- **Verdict: skip tools.** If wanted, a 5-line `.githooks/commit-msg` regex
  (`^(feat|fix|docs|infra|ci|chore)(\(.+\))?!?: .+`) does the job with no dependency.

### 3.16 Hugo-specific checks

- `--printI18nWarnings`: closes gap 6 (verified). With `--panicOnWarning` a missing key fails the build.
  **Adopt now** (one flag in the `check` target). Note for step 2.1: once uk/pl are enabled it will also
  fail on any key missing in those languages, which is the intended rule.
- `--printPathWarnings`: duplicate target paths (two pages writing the same URL). Clean today
  [local run]. **Adopt now** in the same line; becomes valuable at 2.1 (translated slugs).
- `--printUnusedTemplates`: see gap 12. **Adopt as a second in-memory pass with drafts**
  (`hugo --renderToMemory --buildDrafts --printUnusedTemplates --panicOnWarning`, ~20 ms) or leave as an
  occasional manual audit. Verified: 0 warnings with drafts, 2 without.
- `--templateMetrics`: performance only; irrelevant at 15 pages. Skip.
- htmltest https://github.com/wjdp/htmltest : v0.17.0 (2022-11-04), last push 2025-01, MIT; Fedora
  `htmltest 0.17.0`. Effectively unmaintained. Overlaps with lychee (v0.24.2, 2026-05-01, Apache-2.0,
  binary + `.sha256`), which can check the built `public/` offline and is already planned in 2.7.
  **Verdict: skip htmltest, keep lychee at 2.7.**
- Notes for step 2.7 (already planned, so only pinning facts): the Nu HTML checker
  https://github.com/validator/validator publishes only a rolling `latest` release (2026-11-26; the last
  versioned tag is 20.6.30 from 2020) [gh api], so pin the jar by SHA-256 (API digest), not by tag.
  Lighthouse CI is an npm package [web claim]; running it through a SHA-pinned action keeps npm out of
  the repo but not out of the CI job; worth one sentence in an ADR.

### 3.17 Ansible testing below Molecule

- Molecule https://github.com/ansible/molecule : v26.11.1 (2026-11-25), MIT. Planned 3.5; keep there.
- testinfra https://github.com/pytest-dev/pytest-testinfra : 10.2.2 (2025-03-30), last push 2026-07,
  Apache-2.0; Fedora `python3-pytest-testinfra 10.2.2`. Slow-moving; a second language for assertions.
- goss https://github.com/goss-org/goss : v0.4.10 (2026-07-26), Apache-2.0. Another binary + YAML dialect.
- Check mode against a container in CI: the roles that matter here (firewalld, SELinux contexts,
  systemd units, sshd) do not behave in an unprivileged AlmaLinux container, so a green run would prove
  little [web claim / general knowledge]. Skip.
- What costs nothing new: (a) `ansible-playbook --syntax-check` comes with ansible-lint in CI;
  (b) a `playbooks/verify.yml` using `ansible.builtin.assert`, `command` + `changed_when: false`,
  `wait_for`, `uri` to check end state (sshd effective config via `sshd -T`, `getenforce`,
  firewalld services, `ls -Z` label on site_root, HTTP 200); Molecule's default verifier is Ansible, so
  the same file is reused at 3.5; (c) script the lab reset (already an open issue in the roadmap) so
  "fresh VM → run → run again changed=0 → verify" is one make target.
- **Verdict: verify.yml + scripted lab reset: attach to step 1.3 (piece 6 / wrap-up). testinfra, goss,
  container check mode: skip.** Worse than Molecule: runs only on Kai's desktop, not in CI, so nothing
  stops a regression from being pushed.
- Optional later (3.x): scheduled drift detection (`--check` against production, alert on changed≠0).
  Needs sudo-capable credentials outside the desktop, so not in GitHub Actions.

### 3.18 Caddy config validation

- https://github.com/caddyserver/caddy : v2.11.9 (2026-11-05), Apache-2.0. Fedora `caddy 2.10.2`.
  `caddy validate`: "Loads and provisions the provided config, but does not start running it"
  [gh api cmd/commands.go]. `caddy fmt --diff` reports formatting differences [web claim].
- Fit: the Caddyfile is a Jinja template, so the natural gate is on the server at deploy time, exactly
  like the existing `validate: /usr/sbin/sshd -t -f %s`:
  `validate: caddy validate --adapter caddyfile --config %s` on the template task. A broken Caddyfile
  then never replaces the working one. Provisioning may touch log paths/storage, so test it on the lab
  first [could not verify].
- In CI it would need the template rendered and a Caddy binary of the server's version; that is what
  Molecule gives at 3.5.
- **Verdict: attach to step 1.3 piece 5 (caddy role) as a `validate:` argument; `caddy fmt` once by hand
  on the lab. No CI job until 3.5.**

### 3.19 Smaller items found along the way

| Item | Evidence | Verdict |
|---|---|---|
| Vault-header guard in `make lint` (every `*.vault.yml` starts with `$ANSIBLE_VAULT`) | gap 7 | adopt now |
| Dependabot `cooldown` (7 days) | zizmor audit `dependabot-cooldown` [gh api] | adopt now |
| Enable Dependabot alerts; try non-provider secret patterns | [gh api] both off | adopt now (settings only) |
| Close ADR 0006 open question (no attestations/signatures for Hugo or Pagefind) | gap 9 | adopt now (one paragraph in the ADR) |
| `tool-hashes.sh` could read `assets[].digest` from the releases API for tools without a checksum file (shellcheck, zizmor) | [gh api] digest field present | with 3.2/3.4 |
| SECURITY.md (contact + "this is a personal site") | community profile 42 % [gh api] | step 1.7 launch checklist, optional |
| Content-rule checks as code (`tags` in the allowed list, `description` 140–160 chars) in a script like check-i18n.py | [repo file] docs/content-guide.md rules are prose only | step 1.5 |
| Blameless postmortem template next to the runbooks | not present [repo file] | step 3.4 |
| trivy / checkov config scanning, CodeQL, SBOM, signed releases, taplo, hadolint | no Dockerfiles, no releases, no app code | skip |

## 4. Suggested shape (for the implementer; nothing here was changed)

- `make lint` = shellcheck scripts/*.sh → zizmor .github/ → vault-header guard → ansible-lint (in infra/ansible).
- CI: second job `lint` (needs a dummy vault password file; ansible-lint via its SHA-pinned action or a
  version-pinned pipx install).
- `make check`: add `--printI18nWarnings --printPathWarnings` to the strict build.
- versions.env: SHELLCHECK_VERSION, ZIZMOR_VERSION + hashes; given today's date, prefer releases older
  than a week (zizmor v1.33.1 is 5 days old).
- GitHub settings (Kai does these himself in the browser): ruleset on main, `sha_pinning_required`,
  Dependabot alerts.

## 5. Things I could not verify

- Whether zizmor / ansible-lint are green on the current files (not installed; installing was out of scope).
- ansible-lint behaviour in CI with a dummy vault password file (source reading only).
- Whether `secret_scanning_non_provider_patterns` can be enabled on a free public repo.
- Renovate custom-manager config for the versions.env layout end to end.
- `caddy validate` side effects when run by Ansible's `validate:` on a temp file.
- That the tracked vault file is currently encrypted (not opened, per instructions).
- GitHub-hosted runners exposing /dev/kvm for Molecule with real VMs [web claim].
