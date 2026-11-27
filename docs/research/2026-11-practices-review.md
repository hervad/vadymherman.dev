# Practices review, November 2026

**Date:** 2026-11-27 · **Questions:** (1) how should check questions work when Claude writes the
code and Kai must be able to explain it; (2) is the Claude Code setup of this repo in line with the
current docs; (3) would Graphify or other Claude add-ons help here; (4) which engineering practices
does the repo lack?
**Answers:** (1) explain or show first, then ask one narrow question, and always give the answer
afterwards; keep the prediction and the explain-back, in an easier form. (2) Mostly yes; four
small changes. (3) No: skip Graphify and every other add-on for now. (4) One hole in `make check`
closed today; a lint job and branch rules should exist before the deploy pipeline (step 1.4).

## How this was researched

Four parallel research passes (learning research, Claude Code docs audit, third-party add-ons,
repo tooling). Their raw notes are in [2026-11-notes/](2026-11-notes/), unchanged. The claims a
decision rests on were then checked a second time, directly.

Confidence labels:

- **[V] verified:** reproduced locally, read from the GitHub API or a project's own source, or
  read in the primary text (paper, official docs) during the second check.
- **[LC] low confidence:** seen only by a research pass, only as an abstract, or in secondary
  sources. Check before relying on it. The raw notes mark each paper as opened, abstract-only,
  secondary or from memory.

## 1. Check questions

### What the evidence says

| Finding | Source | Label |
|---|---|---|
| Beginners on material with many interacting parts learn more from explanation and worked examples first than from problems first. | Barbieri et al. 2023 (meta-analysis, g = 0.48); Ashman, Kalyuga & Sweller 2020; Rosenshine 2012 | [LC] |
| Watching a demonstration without committing to an outcome teaches almost nothing: correct outcomes later were 61% (no demo), 70% (watch), 77% (predict), 82% (predict + discuss). Only 26% of predictions were right, and students picked from a list of outcomes. | Crouch, Fagen, Callan & Mazur 2004 | [V] |
| A prediction helps through surprise at a confident wrong answer; a blind guess has no confidence behind it, so it brings little. | Brod 2021 | [LC] |
| With the answer given afterwards, a test teaches whether or not the first answer was right (g = 0.73). Without feedback and with half or fewer right, it teaches nothing (g = 0.03). | Rowland 2014 (meta-analysis). Citation checked; the numbers are from the paper body, not reopened. | [LC] |
| About 80% right on the first try is the usual target for questions that follow an explanation. | Rosenshine 2012 (classroom observation, children) | [LC] |
| Prompts to explain in your own words work (g = 0.55), better with a scaffold such as a sentence frame. | Bisra et al. 2018; Rittle-Johnson et al. 2017 | [LC] |
| Ready-made explanations alone feel best and teach least. | Schworm & Renkl 2006 | [LC] |
| Developers who learned a new library with AI scored 50% on a later quiz, 67% without (52 people; biggest gap on debugging). Those who had the AI write code and then asked until they understood it scored highest. Small study, subgroups of 2 to 7. | Shen & Tamkin 2026 (Anthropic) | [V] |
| Students with unrestricted AI help did 17% worse on a later exam and did not notice. | Bastani et al. 2025 | [LC] |
| In the study closest to our setup (questions around AI-written code), learners complained of "constantly guessing what the AI was doing"; the fix was context before every question plus hints after wrong answers. No question pattern gave a statistically significant learning gain. | Kazemitabaar et al. 2025 | [LC] |
| Guidance-first reverses as knowledge grows; for concepts (not procedures) problem-first then wins (g = 0.36). | Kalyuga et al. 2003; Sinha & Kapur 2021 | [LC] |

### Where the evidence disagrees with "just explain first"

- **Keep the prediction**, but make it a choice between 2 or 3 outcomes after the mechanism is
  explained (Crouch 2004).
- **A wrong answer is fine if the right one follows.** The target is about 4 of 5 right, not 5 of 5.
- **A question that repeats the sentence just shown is weak.** It should make Kai use what was
  shown, and the same idea should come back in a later session.
- **Feeling that an explanation made sense is unreliable**, most of all when an AI writes the code.
  So "makes sense" is not accepted as a check, and the explain-back stays.
- **Explain-first is right for now, not for ever.** Familiar topics get the question first.

Open disagreements among researchers: problem-first versus instruction-first, whether recall
practice works for complex material, immediate versus delayed feedback. No study covers
infrastructure code, and the six-step ladder below is a synthesis, not a tested instrument.

### The ladder (easiest to hardest)

| # | Form | Example |
|---|---|---|
| 1 | Pick one of 2–3 | "The task has `notify: restart sshd`. When does sshd restart? A) after that task, every run. B) once at the end, only if the task reported `changed`. C) at the end of every play." |
| 2 | Fill the gap | "The switch is `ln -s releases/<sha> current.tmp && mv -T current.tmp ____`." |
| 3 | Trace or predict one observable | "`firewall-cmd --list-services` prints `ssh`; the diff adds `http` and `https`. What does it print after the run?" |
| 4 | Explain one line in plain words | "The file is named `01-hardening.conf` because sshd ___, so ___." |
| 5 | What-if | "The deploy dies after rsync but before the symlink flip. What does a visitor see?" |
| 6 | Teach-back | "A maintainer asks: why releases plus a symlink instead of rsync into the live folder?" |

Rungs 1–3 right after an explanation; 4 at the end of a step; 2–4 as recall next session; 5–6 at
milestones, only on topics that passed the lower rungs. Two misses: one rung down. Three or four
first-try hits: one rung up.

### Applied

- Global `~/.claude/CLAUDE.md`: learning loop rewritten (8 steps) and a "Question rules" block added.
- [CLAUDE.md](../../CLAUDE.md) loop summary, [field guide](../field-guide.html) (research table,
  loop, ladder), skills `next` and `checkpoint`.
- [docs/recall-queue.md](../recall-queue.md): the questions for the next sessions, with a status
  per item so a missed one comes back.

## 2. Claude Code setup

| Item | Finding | Verdict |
|---|---|---|
| `@docs/roadmap.md` import in CLAUDE.md | "Imports help you organize a long file but don't reduce its context cost"; target is under 200 lines per CLAUDE.md. With imports about 315 lines loaded every session, and the roadmap grows. [V] | **Applied:** import replaced by a pointer. Cost: Claude knows the roadmap only after reading it. |
| Deny rules starting with `./` | `./path` is resolved from the current directory, `/path` from the project root. After a `cd infra/ansible` the rule `Read(./infra/ansible/.vault_pass)` points at the wrong place. [V] | **Applied:** root-anchored copies added; nothing removed. |
| `$schema` in settings.json | Documented; gives validation in the editor. [V] | **Applied.** |
| `.claude/commands/` | "Older format and still works"; skills add `disable-model-invocation`. [V] | **Applied:** six skills created; old files stay until the skills are confirmed to load. |
| Tutor rules as a custom output style | Documented option (`~/.claude/output-styles/`, `keep-coding-instructions: true`). The built-in Learning style asks the user to write code, which is not our split of roles. [V] | **Not now.** It would split the rules over two places and silently do nothing in a project where the style is not selected. Reconsider if the global file passes 200 lines. |
| Stop hook for the definition of done | Prompt hooks are not deterministic; a build after every edit is wasteful. [LC] | Skip. |
| Sandbox, reviewer subagent, plan mode for `/next` | Optional. [LC] | Not now; plan mode is a habit to try, not a change. |
| Allow rule for `ansible-playbook … --syntax-check` | Dead: an ask rule for `ansible-playbook` is evaluated first. [V] | Left as is; the prompt is wanted. |

Also added today, from a transcript scan: allow rules for `dig`, `dnf5 repoquery`, `rpm -q*`,
`ansible-config`, `ansible-doc`, `WebSearch` and seven documentation hosts. Most permission
prompts during the research came from shell functions and loops wrapped around commands that are
allowed anyway; plain single commands avoid them.

## 3. Graphify and other add-ons

**Graphify: skip.** Facts [V] unless marked:

- This repo has 113 tracked files; most of its knowledge is prose, YAML and templates. Graphify's
  own benchmark doc reports about 1x token reduction on a 6-file corpus (vendor claim, [LC]).
- Its installer adds hooks that run before every Bash, Grep, Read and Glob call, a SessionStart
  hook, and a rule in CLAUDE.md to query the graph "before your first grep, search or source-file
  read".
- Its skill installs and upgrades itself unpinned (`uv tool install --upgrade graphifyy`, falling
  back to `pip install … --break-system-packages`). That conflicts with ADR 0006.
- Repository created 2026-04-03, Apache-2.0, two high-severity advisories (2026-09-27,
  2026-11-23), both about indexing untrusted repositories.
- The PyPI name is `graphifyy` (double y); look-alike names exist ([LC]).
- An auto-generated map would replace the hand-built field guide the learning loop depends on.

Worth another look only for a large unfamiliar codebase, pinned, in a throwaway VM.

| Add-on | Verdict | Reason ([LC] unless marked) |
|---|---|---|
| context7 | Skip | Queries go to a third party; official docs via WebFetch are first-party. |
| Serena, codebase-memory-mcp, GitNexus, Understand-Anything | Skip | Same size argument as Graphify. |
| GitHub MCP server | Skip | `gh` already covers it; adds a token and write tools. |
| obra/superpowers, github/spec-kit | Skip | They impose their own workflow over the roadmap and learning loop. |
| claude-mem | Skip | Records every tool call, runs a daemon; native memory and the learning log cover it. |
| repomix, ccusage, rtk | Skip | Repo is small; `/usage` exists; output trimming works against "show the real output". |
| Anthropic plugins (learning style, security guidance) | Skip for now | Duplicates CLAUDE.md; `/security-review` is built in. |
| claude-code-action | Skip | An API secret and a prompt-injection surface in a repo that will hold a deploy key. |
| chrome-devtools-mcp or playwright-mcp | Maybe at step 1.6 | The only one with a concrete job (Lighthouse, both themes); needs npx, so ask first. Try the plain Lighthouse CLI before. |

Adopt now: nothing.

## 4. Repo tooling

| Item | Finding | Verdict |
|---|---|---|
| Missing i18n key | A template key that exists in no language file builds clean under `--panicOnWarning` and ships an empty string; `--printI18nWarnings` makes it fail. `scripts/check-i18n.py` only compares the language files with each other. Reproduced in a scratch copy. [V] | **Applied:** `--printI18nWarnings --printPathWarnings` added to `make check`. |
| Lint job | Nothing lints `infra/ansible`; `make ansible-lint` exists but ansible-lint is not installed. Scripts pass shellcheck 0.11.0. [V] | **Before 1.4:** `make lint` + CI job with shellcheck, ansible-lint (`production` profile), zizmor, and a guard that every `*.vault.yml` starts with `$ANSIBLE_VAULT`. |
| Branch rules | No ruleset or branch protection on `main`; `sha_pinning_required` off; Dependabot alerts off. [LC] | **Before 1.4 (Kai):** settings only. Cost: every change goes through a pull request. |
| Unpushed work | Five commits (step 1.3 and the November refresh) exist only locally. [V] | Kai pushes when ready. |
| `caddy validate` as the template's `validate:` | Same pattern as `sshd -t`. [LC] | Step 1.3, caddy role. |
| `verify.yml` asserts, scripted lab reset | Reusable later as the Molecule verifier. [LC] | Step 1.3 wrap-up. |
| gitleaks as a local hook | The first private key appears at 1.4. [LC] | Step 1.4. |
| Content-rule checks | Turn content-guide rules (tags, description length) into checks. [LC] | Step 1.5. |
| `make outdated` | community.general is already one major behind. [V] | Step 2.7. |
| pre-commit, actionlint, yamllint, shfmt, markdownlint, vale, Renovate, harden-runner, commitlint, htmltest, testinfra | Overlap, npm-only, unmaintained, or too much for three scripts. [LC] | Skip. |

## Sources

Primary texts read in the second check: Crouch et al. 2004, *Am J Phys* 72:835
(<https://www.otffeo.on.ca/wp-content/uploads/sites/2/2014/11/Mazur_demo-article.pdf>);
Shen & Tamkin 2026 (<https://www.anthropic.com/research/AI-assistance-coding-skills>);
Claude Code docs: <https://code.claude.com/docs/en/memory.md>,
<https://code.claude.com/docs/en/output-styles.md>, <https://code.claude.com/docs/en/permissions.md>,
<https://code.claude.com/docs/en/skills.md>; Graphify repository and advisories
(<https://github.com/Graphify-Labs/graphify>).

Everything else, with URL, evidence strength and what was actually opened:
[2026-11-notes/learning-questions.md](2026-11-notes/learning-questions.md),
[claude-code-setup.md](2026-11-notes/claude-code-setup.md),
[claude-tools.md](2026-11-notes/claude-tools.md),
[repo-tooling.md](2026-11-notes/repo-tooling.md).
