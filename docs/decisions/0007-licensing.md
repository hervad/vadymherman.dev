# 0007. License: MIT for code, CC BY 4.0 for writing

- Status: accepted
- Date: 2026-10-08

## Context
The repository is public from step 0.2 as a portfolio piece. Without a license, public code is
"all rights reserved": readers may look but not legally reuse even a snippet. The repo mixes two
kinds of work: infrastructure and templates (useful to copy) and personal writing (should keep
attribution).

## Options considered
1. **MIT for code + CC BY 4.0 for content/**: others can reuse Ansible roles, Caddyfile, CSS
   freely; posts can be shared or translated with credit and a link. Two files to explain.
2. **No license**: maximum control, but nobody can reuse anything, which undercuts the point of a
   public portfolio repo.
3. **MIT for everything**: simplest, but MIT only requires keeping a copyright notice, so posts
   could be republished without a visible credit.

## Decision
Option 1. `LICENSE` (MIT) covers everything except `content/`; `LICENSE-CONTENT` applies CC BY 4.0
to `content/` with a notice and link to the official legal code. No license file inside
`content/` (Hugo would publish it as a page).

## Consequences
GitHub shows "MIT" on the repo page. The site footer should state the content license (add in
step 1.5 or 1.6). Third-party content (quoted logs, screenshots of others' work) inside posts
keeps its own terms and should be marked when used.
