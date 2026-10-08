# 0006. Pin SHA-256 checksums for downloaded build tools

- Status: accepted
- Date: 2026-10-08

## Context
`scripts/install-tools.sh` downloads Hugo (and later Pagefind) from GitHub releases on the laptop
and in CI, and every page of the site is produced by that binary. It used `curl | tar`, so any
corrupted or tampered archive would be unpacked and run without complaint. Both projects publish
official SHA-256 checksums (Hugo: `hugo_<ver>_checksums.txt`; Pagefind: one `.sha256` per asset).

## Options considered
1. **Pin the expected hashes in versions.env**: catches corruption *and* a release swapped after
   we pinned it, because the reference value lives in our repo, not next to the download. Cost:
   two hash lines to update per version bump (eased by `make tool-hashes`).
2. **Fetch the checksum file from the same release at install time**: zero upkeep, catches
   corruption, but an attacker who replaces the archive can replace the checksum file too.
3. **Keep `curl | tar`**: simplest, no protection.

## Decision
Option 1. versions.env holds the version *and* its SHA-256 per architecture; install-tools.sh
downloads to a temp file and refuses to unpack on mismatch. `make tool-hashes` prints new values
from the official checksum files when a version changes.

## Consequences
A version bump is a reviewable diff of version + hashes, the same "trust on first use" model as
SSH host keys or Go's `go.sum`. Doesn't protect against a release that was already malicious when
we pinned it; only signature or provenance verification would. Open question, not yet checked:
whether Hugo or Pagefind publish signatures or GitHub artifact attestations we could verify
(revisit in step 3.5). Tested: correct hash installs, wrong hash exits 1 and unpacks nothing.
