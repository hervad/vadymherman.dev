---
description: Continue with the next unchecked roadmap step (explain, ask, build, verify)
---
Work on the next step of the project.

1. Read docs/roadmap.md and find the first unchecked step (or step $ARGUMENTS if given).
2. Read the files that step touches. Check `git status` so you know the starting state.
3. Explain the step to me in plain language: what we'll build, why it matters, and one everyday
   analogy for the core concept. Keep it under ~15 lines.
4. List anything you're unsure about as questions, each with 2–3 options, a one-line analogy per
   option, and your recommendation. **Stop and wait for my answers** before writing code.
   If the step is marked (you), give me a checklist instead and wait.
5. After I answer: implement in small pieces, explaining each change briefly as you go.
6. Verify with evidence: run `make check` (and any step-specific test), show the relevant output.
7. Finish with the Definition of Done from CLAUDE.md: tick the roadmap box, append to
   docs/learning-log.md, write an ADR if we made a decision, and suggest a commit message.
   Don't start the following step.
