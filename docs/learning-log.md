# Learning log

Concepts explained while building this site, one entry per concept. Claude appends here at the end
of each step. Later, good entries become blog posts.

Format:
- **YYYY-MM-DD, step X.Y, Concept:** one-sentence explanation. *Analogy:* … *Source:* link (optional)

---
- **2026-10-08, step 0.1, Static site generation:** Hugo merges Markdown (`content/`) into templates (`layouts/`) once, at build time, and writes plain files to `public/`; the server only hands files out. *Analogy:* a bakery bakes everything at 6 a.m. instead of a restaurant cooking each order.
- **2026-10-08, step 0.1, make:** a Makefile gives long commands short names (`make check`), so laptop, CI and Claude run the identical thing. *Analogy:* ordering "number 3" from a menu; the kitchen knows the recipe.
- **2026-10-08, step 0.1, Version pinning:** `versions.env` fixes the exact Hugo version for laptop and CI, so "works on my machine" means "works in CI". *Analogy:* a recipe naming the exact flour brand.
- **2026-10-08, step 0.1, Checksums / trust on first use:** a SHA-256 is a file's fingerprint; pinning it in the repo makes the installer refuse any download that differs (tested with a fake hash: exit 1, nothing unpacked). Same model as SSH host keys or `go.sum`. *Analogy:* checking the medicine's tamper seal against the number you wrote down when ordering. *Source:* docs/decisions/0006-pin-tool-checksums.md
- **2026-10-08, step 0.1, Behaviour-preserving refactor:** fixing a deprecation should change code, not output; proved by diffing `public/` before and after (`diff -r` → identical). *Analogy:* replacing a worn pipe without changing the water pressure.
- **2026-10-08, step 0.1, Baseline commit:** commit the untouched starting point first so the next commit's diff shows exactly what changed. *Analogy:* the "before" photo before a renovation.
- **2026-10-08, step 0.1, Commit email privacy:** commits are public forever once pushed; a GitHub no-reply address (`<id>+user@users.noreply.github.com`, set repo-local in `.git/config`) still links them to the profile. *Analogy:* a PO box on public mail.
- **2026-10-08, research, Round trips and connection reuse:** a first visit pays DNS + connection + TLS + request (3–4 round trips, ~130 ms each to the US); later pages reuse the open connection (1 round trip). HTTP/3 (QUIC) merges connection and TLS setup. *Analogy:* dialling and "hello, who's this?" happen once per call, not per question. *Source:* docs/research/2026-10-stack-review.md
- **2026-10-08, research, CDN trade-off:** a CDN puts copies near visitors; for ~1.5 KB pages the US penalty from Warsaw (~0.25–0.5 s first view) stays far under the 2.5 s LCP budget, so no CDN at launch. *Analogy:* corner shops worldwide vs one warehouse in Warsaw. *Source:* ADR 0005, research doc.
- **2026-10-08, research, 14 KB rule:** TCP and QUIC send only ~14 KB before waiting for the first acknowledgement (RFC 9002 §7.2), so a page that fits arrives in one burst; it's a guide, not a cliff. *Analogy:* the first delivery van has a fixed size; anything extra waits for the second trip.
- **2026-10-08, step 0.2, Continuous integration:** every push runs the same `make check` on a fresh GitHub machine, so leftovers on the laptop can't hide a broken build; the badge shows the latest result on `main`. *Analogy:* a building inspector checking every change against the same rulebook, on an empty lot each time.
- **2026-10-08, step 0.2, Pinning actions by SHA:** `uses: actions/checkout@v7` follows a tag the owner can move; a full commit SHA can't be changed, so the code we reviewed is the code that runs. Dependabot opens PRs to bump the SHA. *Analogy:* hiring a named inspector, not "whoever shows up with a v7 badge".
- **2026-10-08, step 0.2, Least privilege in CI:** `permissions: contents: read` and `persist-credentials: false` mean the build job holds no token that could push or change the repo. *Analogy:* the inspector gets a visitor badge, not the master key.
- **2026-10-08, step 0.2, Reading the source beats guessing:** an "unverified" worry (comments in `$GITHUB_ENV`) was settled by reading the runner's open-source parser (FileCommandManager.cs): any line without `=` or `<<` throws `Invalid format`. *Analogy:* checking the rulebook instead of asking around.
- **2026-10-08, step 0.2, Reproducible builds:** the CI artifact matched the local build byte-for-byte except the build-SHA meta tag, which equals the pushed commit; that tag becomes the deploy smoke test in 1.4. *Analogy:* two bakeries, same recipe and flour, identical loaves; only the date stamp differs.
- **2026-10-08, step 0.2, Licensing:** public code without a license is "look, don't touch"; MIT for code + CC BY 4.0 for writing lets others reuse snippets while posts keep attribution. *Source:* docs/decisions/0007-licensing.md
