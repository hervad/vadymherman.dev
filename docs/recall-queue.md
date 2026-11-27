# Recall queue

Questions for the start of each session (learning loop step 7). Claude asks three, one at a time:
the two newest and one older. The answer follows each question, right or wrong.

How an item moves:

```text
new ──asked──► right once ──right again in a later session──► retired (or upgraded to a what-if)
  └──missed──► missed: comes back next session in an easier form (options, or a cue)
```

Rules for the questions are in the global CLAUDE.md ("Question rules"): one idea, answerable
from what was explained, easy forms first. `/checkpoint` adds one question per new learning-log
entry. Kai: don't read the Answer column before a session; it only works from memory.

| # | From (learning log) | Question | Answer | Status |
| --- | --- | --- | --- | --- |
| 1 | 2026-10-10, step 1.3, idempotency | The second run of a finished role shows `changed=0`. Is that A) a sign nothing was applied, B) the proof the role only changes what differs, or C) an error? | B. Each task compares wanted and current state and acts only on a difference; a second run with nothing to do is the test. | new |
| 2 | 2026-10-10, step 1.3, two-phase bootstrap | Run 1 created `kai` and hardened SSH but still allowed the `almalinux` user. Why was it not removed in the same run? | So we could test that `kai` logs in and sudo works before the old way in was closed; otherwise one mistake locks us out. | new |
| 3 | 2026-10-10, step 1.3, sshd drop-ins | Fill the gaps: our file is named `01-hardening.conf` because sshd reads drop-ins in … order and the … value wins. | Alphabetical; first. `50-cloud-init.conf` says `PasswordAuthentication yes`, so ours must come before it. | new |
| 4 | 2026-11-27, refresh, a config line that does nothing | `result_format = yaml` was in `ansible.cfg`, yet the output stayed JSON. Which command shows what Ansible really read: A) `ansible --version`, B) `ansible-config dump --only-changed`, C) `ansible-playbook --syntax-check`? | B. It lists every setting that differs from the default and where it came from; the ignored key was simply absent. | new |
| 5 | 2026-11-27, refresh, pinned hashes | After changing only `HUGO_VERSION` in `versions.env`, `make tools` refuses the download. What else has to change in that file? | The SHA-256 lines (`make tool-hashes` prints them). The installer compares the download with the pinned hash and stops on a mismatch. | new |
| 6 | 2026-11-27, refresh, first list wins | A command matches an exact rule in `allow` and a wider rule in `ask`. Does Claude Code prompt? | Yes. The lists are checked in the order deny, ask, allow, and how specific a rule is does not matter. | new |
| 8 | 2026-11-27, practices review, where a deny rule is anchored | Claude has run `cd infra/ansible`. The rule `Read(./secrets.txt)` now looks for the file in A) the project root or B) `infra/ansible/`? | B. `./` starts from the directory Claude is in at that moment; a rule starting with `/` always starts from the project root. | missed twice on 2026-11-27 in a harder three-rule form; right once the same day in this form. Ask again next session. |
| 9 | 2026-11-27, practices review, DNSSEC | `dig +short DS vadymherman.dev` prints nothing. Does that mean DNSSEC for the domain is A) on or B) off? | B. The DS record at `.dev` is the fingerprint resolvers check signatures against; no DS record means nothing is checked. | new |
| 7 | 2026-11-27, practices review, missing i18n key | A template uses `{{ i18n "x" }}` and no language file has `x`. Before today, did `make check` fail? | No. Hugo printed an empty string and the build passed. `--printI18nWarnings` now turns that into a failed build. | new |
