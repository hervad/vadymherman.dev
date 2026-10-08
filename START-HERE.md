# Start here

## 1. Unzip and open

```bash
mkdir -p ~/projects && cd ~/projects
unzip ~/Downloads/personal-site.zip
code personal-site
```

## 2. Prerequisites on Fedora

```bash
sudo dnf install -y git make python3 curl tar
```

In VS Code, accept the "recommended extensions" prompt (or open the Extensions view and type
`@recommended`). At minimum install **Claude Code**. Ansible tools come later (step 1.3):
`sudo dnf install -y ansible-core ansible-lint`.

## 3. Check it builds (optional, Claude does this too)

```bash
make tools && make check && make serve
```

Open http://localhost:1313. You'll see a plain, readable skeleton; the real design is step 1.2.

## 4. Give Claude Code the first prompt

Open the Claude Code panel in VS Code and paste:

```text
This is a fresh skeleton for my personal website. Before changing anything:
1. Read CLAUDE.md, docs/architecture.md and docs/roadmap.md.
2. Check my environment: run `make tools`, then `make check`, and show me the output. If something
   is missing on my Fedora machine, give me the dnf command instead of working around it.
3. Give me a short tour of the repo: each top-level folder in one line, plus an everyday analogy
   for how Hugo turns content/ into public/.
4. List every TODO( placeholder and which roadmap step handles it.
5. Ask me anything you're unsure about (2–3 options each, a one-line analogy per option, and your
   recommendation), then wait.
When I say go, start step 0.1 using the /next workflow.
```

## 5. Daily rhythm

| Command | When |
|---|---|
| `/next` | Start a session: picks the next roadmap step, explains it, asks, builds, verifies |
| `/explain <thing>` | Anything unclear: a file, a Hugo function, an Ansible module |
| `/review` | Before committing |
| `/checkpoint` | End of a session: roadmap + learning log updated, commit message suggested |
| `/new-post <title>` | New draft post with front matter and an outline (you write the text) |
| `/decision <topic>` | Record why we chose something (ADR) |

Tip: run `/clear` between unrelated tasks so Claude's context stays focused.
