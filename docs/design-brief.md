# Design brief (step 1.2)

**Subject:** personal site of a systems engineer: Linux internals, KVM/hypervisors, kernel-level
root-cause analysis, Ansible automation, moving into DevOps/SRE.
**Audience:** hiring managers and engineers skimming in 30 seconds; readers who stay for long
technical posts with code and logs.
**Primary job:** make the writing and projects easy to read and credible; prove the author cares
about craft and performance.

**Constraints:** system fonts only (or one self-hosted variable font, Latin Extended-A for Polish,
only if clearly justified), CSS < 14 KB, no JS for layout, WCAG 2.2 AA contrast in both themes,
readable code blocks and log excerpts (long lines scroll, don't wrap).

**Process for Claude:**
1. Propose a compact plan: 4–6 named colors (hex) per theme, type scale, a layout described in one
   sentence plus an ASCII wireframe for home and post pages, and 2–3 principles.
2. Check the plan against generic defaults (cream background + serif + terracotta accent;
   near-black + acid-green "hacker" look; identical rounded cards with shadows; ALL-CAPS eyebrow
   labels; "→" on every link). If the plan resembles one, revise and say what changed.
3. Offer 2 directions with a short analogy each; Kai picks; then implement.
4. Spend boldness in one place (e.g. how code/terminal output is presented, which fits the subject);
   keep everything else quiet.
