# Claude Code add-ons: research notes (2026-11-27)

Read-only research. Nothing was installed, no downloaded code was run, no public action was taken.
Source text of Graphify was downloaded as plain `.txt`/`.md` into `research/dl-graphify/` next to
this file and only read with `rg`/`sed`.

## Confidence labels

- **[G]** = "gh api / repo file": read directly from the GitHub API or from a file in the repository
  (higher confidence). For source code this means "the code says so", not "I ran it".
- **[W]** = "README / web claim": vendor README, docs site, issue-thread text written by a reporter,
  WebSearch result, or a WebFetch summary (a small model summarises the page, so details can be off).
  Lower confidence; verify in a browser before relying on it.
- **[L]** = measured locally in this repository with git/wc.
- **[E]** = my estimate or inference. Not measured.

## 0. This repository's real size [L]

- 113 tracked files. Per top-level directory: infra 25, docs 22, layouts 14, static 10, root 10,
  content 8, .claude 7, scripts 4, .vscode 3, i18n 3, assets 3, .github 2, data 1, archetypes 1.
- By type: 38 md, 23 yml, 16 html, 6 woff2, 4 toml, 4 json, 3 txt, 3 sh, 2 j2, 2 css, 1 py, 1 js.
- 4,557 lines of tracked text in total.
- Files Graphify would send through an LLM pass (md, html, j2, txt): 59 files, 239,557 bytes,
  3,448 lines. About 60k tokens of raw text [E, at ~4 bytes per token].
- Files Graphify would parse locally (yml, json, sh, py, js; vault file excluded): about 32 files,
  25,381 bytes.
- Largest files: docs/design/signal-lab.html 79 KB, docs/field-guide.html 34 KB,
  docs/learning-log.md 24 KB, docs/research/2026-10-stack-review.md 15 KB, assets/css/main.css 13 KB.
- Whole text corpus is roughly 265 KB, about 66k tokens [E]. It fits in one context window with room
  to spare, and CLAUDE.md already auto-loads architecture.md and roadmap.md every session.

---

## Part 1. Graphify (https://github.com/Graphify-Labs/graphify)

### 1.1 Identity, age, cadence

- [G] Repo created 2026-04-03; 154,113 stars, 14,834 forks; Apache-2.0; Python; not archived;
  default branch is named `v8` (branches v1..v8 and main also exist).
- [G] Owner is the organisation Graphify-Labs, created 2026-06-28, i.e. after the repo. The old path
  `safishamsi/graphify` resolves to the same repository id (1200597263), so the repo was transferred
  from a personal account to the org.
- [G] NOTICE: "Copyright 2026 Safi Shamsi and the Graphify contributors"; relicensed from MIT to
  Apache-2.0 (LICENSE-MIT kept for earlier contributions).
- [G] Top contributors by commits: safishamsi 1360, ayushcodes10 229, Deepjyoti-Sarmah 142,
  rohit-jsfreaky 75. One dominant maintainer.
- [G] Releases: 15 releases between 2026-11-09 and 2026-11-26 (v0.9.105 to v0.9.121), close to one
  per day. Last 100 commits span only 2026-11-21..26 (37 on one day). CHANGELOG.md is 670 KB.
- [G] A tag `v1.0.0` exists with no matching GitHub release while releases are 0.9.x (meaning unknown).
- [G] Issue tracker: 814 open issues, 943 open PRs, 1,569 closed issues.
- [W] README badges: "YC S26", "ROSS Index Q3 2026 #2 fastest-growing open-source startup". There is
  a commercial hosted product (app.graphify.com) advertised five times in the README.

### 1.2 What it does and how

- [G] docs/how-it-works.md, three passes:
  1. Code structure: tree-sitter AST locally, no LLM (about 40 languages).
  2. Video/audio: local faster-whisper transcription (optional extra).
  3. Docs, papers, images: LLM subagents, "costs tokens". Under Claude Code the running session
     dispatches subagents; headless `graphify extract` needs an API key or a local model.
- [G] Then Leiden/Louvain community detection (networkx), no embeddings, no vector store.
- [G] Outputs in `graphify-out/`: `graph.json` (NetworkX node-link), `graph.html`, `GRAPH_REPORT.md`,
  plus `cache/`, `.graphify_python`, `.graphify_root`, chunk files, optional `wiki/`.
- [G] Query side: `graphify query|path|explain|section` against graph.json; optional stdio MCP server
  (`graphifyy[mcp]`, command `graphify-mcp`).
- [G] File classification (graphify/detect.py lines 48-49):
  - "code" (local): `.py .js .go .sh .json .yaml .yml .tf ...`
  - "docs" (LLM pass): `.md .mdx .txt .rst .html .j2 .jinja .jinja2`
  - So Hugo templates (`layouts/*.html`), Jinja2 templates and every Markdown doc here go to the LLM
    pass. `.toml` and `.css` are in neither set.
- [G] YAML handling (graphify/extractors/yaml_config.py): a file node plus `contains` edges to keys,
  depth-capped. No Ansible semantics: no `notify` to handler, no `template: src=`, no role
  dependency edges (searched the file for those words: only the key probe matches).
  A top-level YAML list counts as config only if an item has a `hosts`, `tasks` or `roles` key;
  otherwise it is skipped as "data yaml". Role files `roles/*/tasks/main.yml` and
  `handlers/main.yml` are lists of task dicts without those keys, so by this code 10 of this repo's
  22 YAML files would be skipped [E from reading the code; not executed]. Flat all-scalar mappings
  (typical `defaults/main.yml`) are also skipped.
- [G] No mention of "ansible" or "hugo" anywhere in extract.py (691 KB).

### 1.3 Vendor claims (all [W]; README / BENCHMARKS.md / how-it-works.md)

- "71.5x fewer tokens per query" on a 52-file mixed corpus; "5.4x" on 4 files; "~1x" on a 6-file
  Python library. The vendor's own text: "Token reduction scales with corpus size. Six files already
  fits in a context window."
- LOCOMO recall@10 0.497, LongMemEval-S 76%: these are conversational-memory benchmarks, not code.
- Code benchmark: ERPNext (about 1M LOC), n=6 questions, 82.0% vs 70.8% for grep/read. Vendor's own
  harness, tiny sample.
- "Zero LLM credits to build the graph" applies to code-only corpora.
- "No telemetry, no usage tracking, no analytics."
- The skill file itself says semantic extraction "can cost minutes and tens of thousands of tokens"
  and that without a graph, a targeted lookup "is faster and free with a plain text search".

### 1.4 How it installs into Claude Code

Package and registry:
- [G] PyPI package name is `graphifyy` (double y); CLI command is `graphify`. Install:
  `uv tool install graphifyy` or `pipx install graphifyy` or `pip install graphifyy`.
- [G] pyproject.toml: 31 runtime dependencies (networkx, numpy, rapidfuzz, pyyaml, tomli,
  tree-sitter, plus 25 tree-sitter grammar wheels with compiled code), all as version ranges, not
  pins. [W] PyPI metadata for 0.9.121 lists the same 31; wheel 2.07 MB, uploaded 2026-11-26.
- [G] Publishing: GitHub Actions `publish.yml`, PyPI trusted publishing (OIDC), triggered by a GitHub
  release. The workflow uses mutable tags (`actions/checkout@v4`, `astral-sh/setup-uv@v6`,
  `pypa/gh-action-pypi-publish@release/v1`), not commit SHAs.

Step A, `graphify install` (global, the README quickstart) [G, graphify/install.py]:
- copies the skill to `~/.claude/skills/graphify/SKILL.md` (50 KB) plus a `references/` folder
  (8 files, about 52 KB) and a `.graphify_version` stamp; keeps one `SKILL.md.bak`;
- appends a `# graphify` block to the user's global `~/.claude/CLAUDE.md` ("When the user types
  /graphify, use the installed graphify skill ... before doing anything else").
- With `--project` it writes `.claude/skills/graphify/` in the repo and creates/edits
  `.claude/CLAUDE.md` in the project instead.

Step B, `graphify claude install` (per project, "always-on") [G, install.py 2385-2447 and
graphify/always_on/claude-md.md]:
- writes a `## graphify` section into the project `CLAUDE.md`. Text includes: run
  `graphify query` "before your first grep, search or source-file read", "put this rule in every
  subagent prompt", "Read raw files only for lines the graph ... already located", "After modifying
  code, run `graphify update .`";
- merges hooks into `.claude/settings.json` (backup `settings.json.graphify-bak`):
  - `PreToolUse`, matcher `Bash|Grep` -> `graphify hook-guard search` (timeout 10 s)
  - `PreToolUse`, matcher `Read|Glob` -> `graphify hook-guard read` (timeout 10 s)
  - `SessionStart`, matcher `compact` -> `graphify hook-guard compact`
  So a subprocess runs before every Bash, Grep, Read and Glob call (source comment: about 170 ms warm)
  and can inject "use the graph" nudges (cap 5 per session). `--strict` lets it deny one Read/Grep
  per session.
- No MCP server is registered by default.

Optional extras:
- [G] `graphify hook install`: git hooks post-commit, post-checkout, post-merge, post-rewrite and a
  merge driver, to rebuild the graph automatically.
- [G] Separate repo Graphify-Labs/graphify-claude-plugin (created 2026-11-16, 2 stars): a Claude Code
  plugin whose `.mcp.json` points at the hosted server `https://api.graphify.com/mcp`. README also
  offers `claude mcp add --transport http graphify https://api.graphify.com/mcp`.
- [G] Skill step 1 ("Ensure graphify is installed") tells the agent to run
  `uv tool install --upgrade graphifyy` or `pip install graphifyy`, falling back to
  `pip install graphifyy --break-system-packages`, with no version pin, and several "do not ask the
  user" instructions.

### 1.5 What leaves the machine

- [G/W] Code files: parsed locally. GitHub code search over `graphify/*.py` found no `posthog`,
  `sentry_sdk`, `mixpanel`, `segment` and no `api.graphify.com`; `urlopen` only in security.py
  (the URL-fetch guard used by `graphify add <url>`). This supports, but does not prove, "no telemetry".
- [G] Docs/HTML/Jinja2/images: under Claude Code they are read by Claude subagents, i.e. sent to
  Anthropic exactly as any file Claude reads. No new party, but it is the whole doc set at once.
- [G] Headless mode auto-selects a provider from whichever API key is set, priority
  Gemini -> Kimi (Moonshot, China) -> Claude -> OpenAI -> DeepSeek -> Azure -> Bedrock -> Ollama.
  `GRAPHIFY_BACKEND=none` disables it.
- [G] Local query log: every query is appended to `~/.cache/graphify-queries.log`
  (opt out with `GRAPHIFY_QUERY_LOG_DISABLE=1`).
- [G] Hosted MCP / app.graphify.com: opt-in; the graph would then live on the vendor's servers.
- [G] Secrets: detect.py skips `.env*`, key/cert extensions, ssh key names, and config files whose
  name contains secret/credential/password/token. `secrets.vault.yml` matches the keyword rule.
  `.vault_pass` matches no pattern; it is only protected because Graphify honours `.gitignore`.
  Graphify runs as its own process, so Claude Code's `Read(...)` deny rules do not apply to it.

### 1.6 Token cost for this repo [E unless marked]

- [G] Skill rule: one general-purpose subagent per chunk of 20-25 doc files or about 6000 lines.
  59 doc-type files -> 3 subagents.
- [E] First build: about 60k tokens of file content, plus the 50 KB skill (about 12k tokens), the
  9.7 KB extraction spec per subagent, subagent system prompts and repeated context across turns.
  Realistic total 150k-300k tokens for the first build. Not measured.
- [E] Updates: per-file SHA-256 cache, so only changed docs are re-read; but docs/learning-log.md and
  docs/roadmap.md change every session, so some re-extraction every session.
- [E] Ongoing: every `/graphify` use loads the 12k-token skill; each query returns up to 2,000 tokens
  (default budget); hook nudges add a little per session.
- [E] Break-even: the things a graph would replace (architecture.md, roadmap.md, CLAUDE.md) are already
  in context for free, and the rest of the repo is about 40k tokens. There is no realistic number of
  queries at which the graph pays back.

### 1.7 Security-relevant history

- [G] Two published GitHub advisories, both high severity, no CVE id:
  - GHSA-g6c9-j4vm-mwq4 (published 2026-11-23): indexing a repository stats UNC paths chosen by the
    repository, coercing outbound SMB authentication; affected >= 0.9.50, < 0.9.115.
  - GHSA-pcc4-rvhr-2pr8 (published 2026-09-27): Fortran extractor allowed arbitrary host-file read
    when indexing an untrusted repo; affected < 0.9.70.
  Both concern indexing an untrusted repository, which is not this use case; they show the parser
  surface is large and that fixes are published.
- [G] Issue titles and states (the content of each is the reporter's claim, so [W]):
  - #5182 open (2026-11-12): "Security review: destructive deletes + never-ask autonomy + unpinned
    remote run in the skill". I confirmed the unpinned install lines and "do not ask" wording in
    skill.md myself [G]; the `rm -f` lines are scoped to graphify-out/.
  - #2167 closed (2026-07-24): "claude install --strict overwrites the entire ~/.claude/settings.json
    ... with no backup" on 0.9.25. Current code merges and writes a `.graphify-bak` [G].
  - #2011 open since 2026-07-18, 0 comments: private vulnerability reporting returns HTTP 500.
  - #4259 open: request for a CVE id for the September advisory.
  - #3869 closed: `core.hooksPath` from the repository redirects `graphify hook install`.
  - #1210 closed: prompt injection, source files concatenated raw into LLM prompts (now wrapped in
    `<untrusted_source>` blocks per SECURITY.md).
  - #280 closed as not planned (2026-04-12): "Possible name squatting" on the single-y PyPI name.
  - #126 closed: maintainer reply says the double y is "intentional while the single-y name is being
    reclaimed".

### 1.8 Names and look-alikes

- [G] Repo and CLI are `graphify`; PyPI package is `graphifyy`. README: "Other graphify* packages on
  PyPI are not affiliated."
- [W] `https://pypi.org/pypi/graphify/json` returned HTTP 404 on 2026-11-27: there is currently no
  installable single-y package. Whether the name is free, reserved or blocked is not verified.
- [W] PyPI `graphify-cli` exists and is unrelated: author "chiheb ben cheikh", homepage
  github.com/ChihebBENCHEIKH1/graphify, one release 0.1.0 on 2026-08-25, similar description.
- [W] PyPI `graphify-ai` and `graphify-mcp`: 404.
- [W] npm `graphify` exists and is unrelated (2015, "RGG (Random Graph Generator)").
- [W] WebSearch found no confirmed malicious look-alike; several third parties flagged the double-y
  name as a typosquat by mistake.
- Risk in plain words: the natural thing to type (`pip install graphify`) is not the real package,
  and the skill itself installs by name without a pin.

### 1.9 Where it helps, and the estimate for this repo

- Helps [E, consistent with vendor text]: large or unfamiliar codebases (tens of thousands of lines
  and up) in tree-sitter languages with real call/import structure; mixed corpora with many papers
  or PDFs; many repeated structural questions; teams sharing one committed graph.
- This repo [E]:
  - Too small: 113 files, 4.5k lines. The vendor's own table shows about 1x at 6 files.
  - Wrong shape: 1 Python file, 3 shell scripts, 1 JS file are the only AST targets. The knowledge is
    prose, YAML and Go templates. Prose and templates go through the paid LLM pass; YAML becomes a
    key tree with no Ansible meaning, and role task files appear to be skipped.
  - Already mapped by hand: architecture.md (mermaid), roadmap.md, field-guide.html, ADRs. The learning
    loop says the owner builds and updates that map himself; an auto-generated graph replaces the
    exercise that is the point of the project.
  - Conflicts with stated rules: unpinned install and near-daily releases vs "pinned by version and
    SHA-256"; edits to CLAUDE.md, `~/.claude/CLAUDE.md` and `.claude/settings.json`; a hook on every
    Read/Grep/Bash; an instruction to query the graph instead of reading files vs "evidence over
    confidence"; `pip` is on the project's ask list.
- Verdict: skip. Revisit only if the owner later works on a large unfamiliar codebase (for example an
  upstream contribution to a big project), and then in a throwaway directory or VM, pinned to one
  version, CLI only (no `claude install`, no hooks), with `GRAPHIFY_BACKEND=none --code-only`.

---

## Part 2. Survey of other add-ons

Discovery sources [G]: GitHub search `topic:claude-code` and `topic:mcp-server` sorted by stars;
`anthropics/claude-plugins-official` (plugins/ and external_plugins/ listings);
`hesreallyhim/awesome-claude-code` README (sections "Infrastructure & DevOps", "Memory & Context
Persistence", "Usage & Cost"); GitHub searches for "ansible mcp", "hugo mcp", "ansible claude skill".

Facts table, all [G] from one GraphQL query on 2026-11-27 (none archived):

| Repo | Stars | License | Created | Last commit | Latest release |
|---|---|---|---|---|---|
| upstash/context7 | 65,543 | MIT | 2025-03-26 | 2026-11-27 | context7-mcp 4.9.1, 2026-11-27 |
| oraios/serena | 31,748 | GPL-3.0-or-later app, MIT SolidLSP | 2025-03-23 | 2026-11-24 | v2.1.0, 2026-10-19 |
| github/github-mcp-server | 34,801 | MIT | 2025-03-04 | 2026-11-27 | v2.3.0, 2026-11-24 |
| obra/superpowers | 328,007 | MIT | 2025-10-09 | 2026-11-03 | v7.0.2, 2026-11-03 |
| anthropics/claude-plugins-official | 48,430 | Apache-2.0 | 2025-11-20 | 2026-11-25 | none (rolling) |
| anthropics/skills | 201,320 | no repo-level licence (README: many Apache-2.0, document skills source-available) | 2025-09-22 | 2026-11-16 | none |
| thedotmack/claude-mem | 120,125 | Apache-2.0 | 2025-08-31 | 2026-11-26 | v17.0.2, 2026-11-26 |
| github/spec-kit | 152,036 | MIT | 2025-08-21 | 2026-11-25 | v1.4.5, 2026-11-25 |
| yamadashy/repomix | 29,471 | MIT | 2024-07-13 | 2026-11-26 | v1.19.0, 2026-11-08 |
| ccusage/ccusage (was ryoppippi/ccusage) | 19,620 | MIT | 2025-05-29 | 2026-11-27 | v20.1.2, 2026-11-25 |
| anthropics/claude-code-action | 10,098 | MIT | 2025-05-19 | 2026-11-25 | v1.0.290, 2026-11-25 (moving `v1` tag) |
| DeusData/codebase-memory-mcp | 49,245 | MIT | 2026-02-24 | 2026-11-27 | v0.12.1, 2026-10-16 |
| Egonex-AI/Understand-Anything | 94,672 | MIT | 2026-03-15 | 2026-11-25 | v2.9.8, 2026-11-15 |
| abhigyanpatwari/GitNexus | 48,934 | non-standard | 2025-08-02 | 2026-11-27 | v1.6.12, 2026-09-12 |
| ChromeDevTools/chrome-devtools-mcp | 59,579 | Apache-2.0 | 2025-09-11 | 2026-11-27 | v1.14.0, 2026-11-24 |
| microsoft/playwright-mcp | 40,210 | Apache-2.0 | 2025-03-21 | 2026-11-18 | v0.0.86, 2026-11-18 |
| rtk-ai/rtk | 88,021 | Apache-2.0 | 2026-01-22 | 2026-11-27 | v1.2.1, 2026-11-19 |
| ansible/vscode-ansible | 495 | MIT | 2020-12-29 | 2026-11-25 | v26.11.1, 2026-11-26 |
| ansible-collections/ansible.mcp | 18 | GPL-3.0 | 2025-09-11 | 2026-11-19 | none |
| akin-ozer/cc-devops-skills | 345 | Apache-2.0 | 2025-12-05 | 2026-07-26 | v1.0.0, 2026-03-04 |
| realsigridjin/hello-ansible-skills | 96 | MIT | 2026-01-17 | 2026-01-17 | none |
| trailofbits/skills | 8,467 | CC-BY-SA-4.0 | 2026-01-14 | 2026-11-12 | none |

Per add-on notes (install lines are [W] from each README unless marked):

1. **context7** (upstash). Purpose: fetch current library docs into the prompt.
   Install: `npx ctx7 setup` (Node >= 22.13, OAuth sign-in, generates an API key, installs a skill or
   MCP), or remote MCP `https://mcp.context7.com/mcp` with a bearer key. Listed in Anthropic's
   marketplace under external_plugins [G].
   Fit: medium. CLAUDE.md names Hugo API drift as a real risk. But the rule there is "read the release
   notes for each version skipped", which is a first-party source.
   Risk: queries (library name plus question) go to Upstash; docs are a community-built index, so
   content is third-party text entering the prompt; Node toolchain.
   Native overlap: WebFetch/WebSearch on gohugo.io, docs.ansible.com, caddyserver.com.
   Verdict: skip.

2. **Serena** (oraios). Purpose: LSP-backed symbol search and editing over MCP.
   Install: `uv tool install -p 3.13 serena-agent`; README warns "Do not install Serena via an MCP or
   plugin marketplace". Language list includes Ansible, Bash, HTML, YAML.
   Fit: low. About 25 KB of YAML and three shell scripts have no symbol graph worth indexing.
   Risk: GPL-3.0 application, Python tool plus language servers downloaded on demand.
   Native overlap: Grep/Glob/Read, and Claude Code's own LSP plugins. Verdict: skip.

3. **GitHub MCP server** (github). Purpose: GitHub API as MCP tools.
   Install: remote `https://api.githubcopilot.com/mcp/` (OAuth) or Docker image with a PAT.
   Fit: low. `gh` is installed and `Bash(gh api *)`, `Bash(gh run *)` are already allowed in
   .claude/settings.local.json [L].
   Risk: a broad token in an MCP config; many tool schemas loaded into context; write tools exist,
   which conflicts with "never perform public actions".
   Native overlap: `gh` CLI. Verdict: skip.

4. **superpowers** (obra). Purpose: opinionated workflow skills (brainstorm, plan, subagent-driven
   development, TDD) with a SessionStart hook.
   Install: `/plugin install superpowers@claude-plugins-official`.
   Fit: low. It imposes its own process on top of a project that already has one (roadmap, /next,
   learning loop, one step per session); subagent-heavy flows hide work from the reviewer.
   Risk: [W] "visual companion telemetry": a logo is loaded from the vendor's site carrying the plugin
   version. Shell hooks run at session start. Verdict: skip.

5. **Anthropic official marketplace** (anthropics/claude-plugins-official, plus anthropics/skills).
   First-party; README of one plugin says the marketplace "ships enabled by default" [W].
   Relevant plugins [G]: learning-output-style, explanatory-output-style, security-guidance,
   claude-md-management, hookify, commit-commands, code-review, plugin-dev.
   - learning-output-style: a SessionStart hook that injects "ask the user to write 5-10 lines"
     instructions. Its README warns about token cost. The global CLAUDE.md learning loop is already
     more specific (predict from evidence, explain back, fade the help). Fit: low, duplicate.
   - security-guidance: regex warnings on Edit/Write, an LLM diff review at the end of each turn
     (newest Opus by default) and an agentic review on `git commit`. Patterns target application
     code (XSS, SSRF, pickle, innerHTML). Costs tokens every turn. Native overlap: the built-in
     `/security-review` and `/code-review` skills. Fit: low-medium.
   - claude-md-management, hookify: one-off helpers. Fit: low.
   Risk: lowest of the survey (same vendor as Claude Code, no new registry), still hooks and tokens.
   Verdict: nothing now. Use the built-in `/security-review` at steps 1.4 and 1.6.

6. **claude-mem** (thedotmack). Purpose: record every tool call and replay summaries in later sessions.
   Install: `npx claude-mem install` (browser sign-in by email) or `/plugin marketplace add
   thedotmack/claude-mem`. Local worker service, SQLite + Chroma in `~/.claude-mem`.
   [W] "Anonymous usage analytics are on by default"; cloud sync opt-in; a hosted paid tier with a
   30-day trial.
   Fit: low. Risk: high: it captures what the agent reads and runs, in a repo that works next to an
   Ansible vault and SSH keys; background daemon; analytics on by default.
   Native overlap: auto-memory (MEMORY.md), CLAUDE.md, docs/learning-log.md. Also the learning loop
   wants recall from the owner's memory, not the tool's. Verdict: skip.

7. **spec-kit** (github). Purpose: spec -> plan -> tasks -> implement slash commands.
   Install: `uv tool install specify-cli`, `specify init`; writes `.specify/` and many `/speckit-*`
   commands into the repo.
   Fit: low: duplicates roadmap.md, ADRs, /next and /decision. Verdict: skip.

8. **repomix** (yamadashy). Purpose: pack a repo into one AI-friendly file.
   Install: `npx repomix@latest` or `brew install repomix`. Uses Secretlint to drop credential files.
   Fit: low: the repo is about 265 KB of text and Claude Code reads files directly.
   Verdict: skip.

9. **ccusage** (now ccusage/ccusage). Purpose: token/cost reports from local Claude Code logs.
   Install: `npx ccusage@latest` or `bunx ccusage`; has `--offline`; statusline mode.
   [G] Repo transferred from ryoppippi/ccusage (old path resolves to the same repo id); primary
   language is now Rust.
   Fit: low-medium (nice numbers for a blog post). Risk: low; reads `~/.claude` logs; fetches pricing
   data unless `--offline`; npx is on the project's ask list.
   Native overlap: `/usage`, `/cost`, `/stats`. Verdict: skip.

10. **claude-code-action** (anthropics). Purpose: Claude in GitHub Actions for PR review and @claude.
    Install: `/install-github-app`; needs `ANTHROPIC_API_KEY` or `CLAUDE_CODE_OAUTH_TOKEN` as a repo
    secret.
    Fit: low for a solo repo where Claude wrote the code and the owner reviews every diff locally.
    Risk: a paid credential stored in a public repo that will also hold a deploy key; prompt injection
    through PR and issue text; moving `v1` tag (the project pins actions by SHA, which covers that).
    Native overlap: `/code-review`, `/review` locally. Verdict: skip. Reconsider at 2.7 only as a
    deliberate learning exercise.

11. **Graph/index competitors**: codebase-memory-mcp (single C binary, `curl ... install.sh | bash`,
    hooks on by default, a per-account daemon, README badge "SLSA 3", README says it traces "Ansible
    tasks and handlers"); Understand-Anything (teaching-oriented graph); GitNexus.
    Fit: low for the same size reason as Graphify. Verdict: skip all.

12. **chrome-devtools-mcp** (Google) / **playwright-mcp** (Microsoft). Purpose: let the agent drive a
    real browser: screenshots of both themes, console errors, performance traces.
    Install: `npx -y chrome-devtools-mcp@latest` as an MCP server; `claude mcp add playwright npx
    @playwright/mcp@latest`.
    [W] chrome-devtools-mcp: "Google collects usage statistics ... enabled by default"
    (`--no-usage-statistics`); performance tools may send URLs to the CrUX API
    (`--no-performance-crux`). Playwright's README says coding agents may be better served by its
    CLI + skills than by MCP.
    Fit: medium, the only add-on with a concrete job here: step 1.6 "Lighthouse 100 on all four
    categories" and step 2.7 Lighthouse CI.
    Risk: Node via npx (ask list; needs the owner's approval under "no npm ... without asking");
    unpinned `@latest` in the documented config; telemetry on by default.
    Native overlap: none for rendering; but the Lighthouse CLI or Lighthouse CI in GitHub Actions
    gives the same numbers without an agent add-on.
    Verdict: adopt at a later step (1.6), optional, pinned to one version with both opt-out flags,
    and only if the plain Lighthouse CLI proves insufficient.

13. **Ansible- and Hugo-specific**.
    - ansible/vscode-ansible contains `packages/ansible-mcp-server` [G]; tool list not checked.
    - ansible/aap-mcp-server targets Ansible Automation Platform (not used here).
    - ansible-collections/ansible.mcp is the reverse direction: Ansible modules that call MCP servers.
    - Community skills: akin-ozer/cc-devops-skills (ansible-validator, github-actions-validator
      among 18 skills [G]; last push 2026-07-26), realsigridjin/hello-ansible-skills (all commits on
      one day).
    - Hugo MCP servers: largest has 10 stars [G].
    Fit: low. Ground truth for this repo is `ansible-lint`, `--syntax-check`, `--check --diff` on the
    lab VM, all already wired into the Makefile and allow list.
    Verdict: skip the add-ons; roadmap 3.5 (ansible-lint in CI, Molecule) is the right vehicle.

14. **rtk** (and similar: context-mode, caveman, headroom). Purpose: a hook that rewrites shell
    commands and compresses their output to save tokens.
    Install: `brew install rtk` or `curl ... install.sh | sh`, then `rtk init -g`.
    Fit: low, and it works against two project rules: "evidence over confidence: show the output" and
    the learning loop's "read the real output against the prediction".
    Verdict: skip.

### Overall

- Adopt now: nothing.
- Later, optional: a browser MCP at step 1.6, pinned and with telemetry off.
- Already covered natively: memory (auto-memory + docs), review (`/code-review`, `/security-review`),
  cost (`/usage`), GitHub (`gh`), docs lookup (WebFetch), learning mode (CLAUDE.md), custom commands.

---

## Could not verify

- Whether the single-y PyPI name `graphify` is free, reserved or blocked (only saw a 404 from the
  JSON API via WebFetch). The curl lookup was declined, so no direct registry query was made.
- PyPI totals for `graphifyy`: number of releases, whether any were yanked (the JSON was too large for
  WebFetch; first visible upload 0.1.1 on 2026-04-04). Whether PyPI attestations exist for 0.9.121
  (the summary saw no provenance field; attestations are served by a different API).
- "No telemetry": checked by keyword search only, not by auditing about 3 MB of Python. The hosted
  product's privacy policy (graphify.com/privacy) was not read.
- docs.graphify.com pages (configuration, always-on setup) were not read; install behaviour above
  comes from the source code instead.
- Real token cost of a first build on this repo: estimate only, nothing was run.
- Whether Ansible role task files are really skipped by the YAML extractor: read from the code, not
  executed.
- How well the LLM pass handles Hugo Go templates in `.html`: not tested.
- The meaning of the `v1.0.0` tag and the `v1`..`v8` branches.
- Whether the star counts (154k in under 8 months; several repos above 100k) are organic.
- Everything quoted from issue threads (#126, #280, #2011, #2167, #4259, #5182) is the reporter's or
  maintainer's claim. Verify in a browser.
- Tool list and data handling of `ansible-mcp-server`; context7's data retention; claude-mem's
  analytics contents and pricing; `SLSA 3` badge of codebase-memory-mcp.
- Whether `uv` or `pipx` is installed on this machine (not checked; irrelevant to a skip verdict).

## Process note: a declined command and the permission rules

One Bash call (a `for` loop of `curl` requests to pypi.org and registry.npmjs.org, public metadata
only) was declined with the note "add the bash commands to allowed". I did not change any settings:

- `.claude/settings.json` (tracked) has `"ask": ["Bash(curl:*)", ...]`.
- Claude Code evaluates rules "deny, then ask, then allow", and an ask rule fires for any matching
  subcommand, including inside a `for` loop (https://code.claude.com/docs/en/permissions).
- So an allow entry for curl would have no effect unless the tracked ask rule is removed or narrowed,
  and the saved preference says the curl prompt is kept on purpose.

I switched to `gh api` (already allowed) and WebFetch instead. If prompt-free registry lookups are
wanted, the owner's options are: (a) leave it as is; (b) add `WebFetch(domain:pypi.org)` and
`WebFetch(domain:registry.npmjs.org)` to the allow list, which keeps the curl guardrail intact.

## URLs

- https://github.com/Graphify-Labs/graphify (README, SECURITY.md, RELEASING.md, pyproject.toml,
  graphify/install.py, graphify/detect.py, graphify/extractors/yaml_config.py, graphify/skill.md,
  graphify/always_on/claude-md.md, docs/how-it-works.md, BENCHMARKS.md, .github/workflows/publish.yml)
- https://github.com/Graphify-Labs/graphify/security/advisories/GHSA-g6c9-j4vm-mwq4
- https://github.com/Graphify-Labs/graphify/security/advisories/GHSA-pcc4-rvhr-2pr8
- https://github.com/Graphify-Labs/graphify/issues/5182 , /issues/2167 , /issues/2011 , /issues/280 ,
  /issues/126 , /issues/4259
- https://github.com/Graphify-Labs/graphify-claude-plugin
- https://pypi.org/project/graphifyy/ , https://pypi.org/project/graphify-cli/ ,
  https://www.npmjs.com/package/graphify
- https://code.claude.com/docs/en/permissions
- https://github.com/anthropics/claude-plugins-official , https://github.com/anthropics/skills
- https://github.com/hesreallyhim/awesome-claude-code
- https://github.com/upstash/context7 , https://github.com/oraios/serena ,
  https://github.com/github/github-mcp-server , https://github.com/obra/superpowers ,
  https://github.com/thedotmack/claude-mem , https://github.com/github/spec-kit ,
  https://github.com/yamadashy/repomix , https://github.com/ccusage/ccusage ,
  https://github.com/anthropics/claude-code-action , https://github.com/DeusData/codebase-memory-mcp ,
  https://github.com/Egonex-AI/Understand-Anything , https://github.com/ChromeDevTools/chrome-devtools-mcp ,
  https://github.com/microsoft/playwright-mcp , https://github.com/rtk-ai/rtk ,
  https://github.com/ansible/vscode-ansible , https://github.com/ansible-collections/ansible.mcp ,
  https://github.com/akin-ozer/cc-devops-skills , https://github.com/realsigridjin/hello-ansible-skills
- WebSearch results used for the look-alike check: https://socket.dev/pypi/package/graphifyy ,
  https://ai.dosa.dev/blog/code-knowledge-graph-tools-ai-coding-agents ,
  https://repowise.dev/blog/comparisons/graphify-review-and-alternatives ,
  https://explainx.ai/blog/graphify-codebase-knowledge-graph-skill-claude-code-cursor-codex-trending-2026
