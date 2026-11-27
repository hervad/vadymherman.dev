# Claude Code setup audit: vadymherman.dev (2026-11-27)

Read-only audit against code.claude.com docs fetched on 2026-11-27. "Not found in docs" means the page I read did not contain it.

## Prioritized changes

### High

1. **Stop loading the roadmap into every session.** Always-loaded instructions here: project CLAUDE.md (68 lines) + docs/architecture.md (48 lines, 2,473 bytes) + docs/roadmap.md (154 lines, 12,159 bytes) + docs/content-guide.md (45 lines, 2,041 bytes) + global CLAUDE.md (6,071 bytes). The roadmap is the largest and grows with progress notes.
   - Change: remove `@docs/roadmap.md` from CLAUDE.md and replace it with a one-line pointer. /next already reads the roadmap. Move content-guide into `.claude/rules/content.md` with `paths: ["content/**"]`.
   - Why: "Imports help you organize a long file but don't reduce its context cost, because imported files load together with the CLAUDE.md that imports them." https://code.claude.com/docs/en/memory.md
   - Also: "target under 200 lines per CLAUDE.md file" (same page). With imports, this setup loads about 315 lines of project instructions.
   - Verify: run `/context all` before and after, per https://code.claude.com/docs/en/best-practices.md
   - Cost: Claude knows roadmap state only after reading the file, so /next must read it first.

2. **Put the tutor behaviour in a custom output style, not the built-in Learning style.** Built-in Learning "also asks you to write some of the code" (leaves TODO(human) markers). That contradicts your roles (Claude writes, you explain).
   - Change: create `~/.claude/output-styles/tutor.md` with `keep-coding-instructions: true` and the explain, predict, check-question rules. Select it with `/output-style tutor`, which saves to `.claude/settings.local.json`.
   - Why: "Set `keep-coding-instructions: true` if you're changing how Claude communicates but still want it coding the same way." Built-in names: Proactive, Concise, Explanatory, Learning. https://code.claude.com/docs/en/output-styles.md
   - Trade-offs: it shrinks the global CLAUDE.md in every repo. But the style is still an instruction: "It doesn't guarantee that something always happens or never happens." Subagents do not get it. Edits to a style need a restart. Stateful steps (predict, recall) fit a SessionStart hook: hook stdout "is treated as plain text" and added to Claude's context (https://code.claude.com/docs/en/hooks.md). That hook could inject the last learning-log lines.
   - Cost: the learning rules are split across two places.

3. **Tighten the secret deny rules.** Current rules use valid syntax. Read deny does block `cat`: "they also apply to redirection targets and to file commands it recognizes, such as `cat`, `head`, `tail`, `sed`, and `tee`." https://code.claude.com/docs/en/permissions.md
   - Gaps: "They don't apply to a command that reads files without naming them, such as `grep -r pattern .` ... They also don't apply to arbitrary subprocesses ... like a Python or Node script that opens files itself." (same page)
   - Add `Read(./.env.*)`, as the docs example includes `Read(./.env.local)` (https://code.claude.com/docs/en/memory.md). Consider `Read(~/.config/gh/**)` if gh keeps its token in a file (my suggestion, not from the docs).
   - Note: `./path` means "relative to current directory", while `/path` means "relative to the settings source" (project root). Use `/` if you launch Claude from subdirectories.
   - Cost: deny rules cannot stop arbitrary scripts. That needs the sandbox (item 6).

### Medium

4. **Use plan mode for /next's stop-and-wait step.** "Claude reads files and proposes a plan but makes no edits until you approve." Start with `claude --permission-mode plan` or Shift+Tab. https://code.claude.com/docs/en/common-workflows.md#plan-before-editing
   - Cost: one more mode to switch out of.

5. **Optional read-only reviewer subagent.** Add `.claude/agents/reviewer.md` with `tools: Read, Grep, Glob`. "Now it's a reviewer that can't edit anything, and that limit is enforced by Claude Code rather than requested in a prompt." https://code.claude.com/docs/en/best-practices.md. Subagents are defined with `name`, `description`, `tools`, `model`; the file goes in `.claude/agents/` (https://code.claude.com/docs/en/sub-agents.md).
   - Cost: "every subagent sends its own requests and they count against the same usage." The subagent also inherits CLAUDE.md. /review already covers most of this.

6. **Sandbox: optional, with limits.** "The sandbox is off by default. To turn it on, run `/sandbox`..." https://code.claude.com/docs/en/sandboxing.md. Its default reads include "credential files such as `~/.ssh` and `~/.aws/credentials`", so the deny rules still matter. "Permission rules and sandboxing are complementary layers." Its network allowlist "start[s] empty", so ssh, rsync and curl to the VPS would need allowlisting or exclusion. Docker is incompatible.

### Low

7. **Command files to skills (optional).** "a Markdown file in `.claude/commands/` is the older format and still works... Prefer a skill for new work, since skills also support supporting files." https://code.claude.com/docs/en/skills.md. This is the only item the docs mark as older. If you migrate, add `disable-model-invocation: true` to side-effect commands ("like `/commit`, `/deploy`"): /checkpoint, /new-post, /decision. Keep SKILL.md under 500 lines.

8. **No Stop hook for the Definition of Done.** "A `prompt` or `agent` hook asks another model to decide, so it isn't deterministic either." https://code.claude.com/docs/en/best-practices.md. Claude Code also "overrides a Stop hook after it blocks eight times in a row" (https://code.claude.com/docs/en/hooks-guide.md). A PostToolUse hook running `make check` would rebuild the whole site on every edit. Keep the DoD in /checkpoint and /review.

9. **Context habits already match the docs.** "`/clear` between unrelated tasks. It costs nothing" (best-practices). One roadmap step per session is that pattern. Note: "a file that only a Bash command touched isn't restored" by /rewind (https://code.claude.com/docs/en/checkpointing.md), so Ansible or make writes can't be rewound.

## Checked and already fine

- Ask rules for commit, push, ssh, rsync, curl and ansible: "a matching ask rule prompts even when a more specific allow rule also matches the same call," and an ask rule "still prompts you ... even in auto mode" (permissions.md). Your setup holds.
- Project CLAUDE.md is 68 lines, under the 200-line guidance by itself.
- Import paths resolve relative to the importing file, so `@docs/...` is correct.
- Command descriptions lead with the use case, as the skills page recommends.
- The Read deny rules `Read(~/.ssh/**)`, `Read(./infra/ansible/.vault_pass)` and `Read(./infra/ansible/**/*.vault.yml)` are valid.

## Extra quotes

- Hook events confirmed in the pages I read: SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, PermissionDenied, Stop, StopFailure, SubagentStop, FileChanged, CwdChanged, ConfigChange, SessionEnd, InstructionsLoaded, PostToolBatch. The full lifecycle table is in https://code.claude.com/docs/en/hooks.md#hook-lifecycle.
- "PreToolUse hooks don't run when Claude Code includes a file you reference with `@`, because it makes no tool call." (https://code.claude.com/docs/en/common-workflows.md)
- "Keep the enforced set small. ... If you ever find yourself at forty of them, most are probably preferences." (https://code.claude.com/docs/en/best-practices.md)
- "`/doctor` suggests cuts for anything Claude can already work out from the code." (https://code.claude.com/docs/en/best-practices.md)
- "Custom commands have been merged into skills. Your existing `.claude/commands/` files keep working." (https://code.claude.com/docs/en/skills.md)
- "Put the key use case first: the combined `description` and `when_to_use` text is truncated at 1,536 characters." (https://code.claude.com/docs/en/skills.md)
- "Rules without `paths` frontmatter are loaded at launch with the same priority as `.claude/CLAUDE.md`." (https://code.claude.com/docs/en/memory.md)
- Not found in docs: a dedicated page for `keep-coding-instructions` beyond output-styles.md; a documented token budget for the skill listing.
