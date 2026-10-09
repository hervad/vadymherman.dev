#!/usr/bin/env bash
# Downloads the self-hosted web fonts into static/fonts/ (ADR 0009) and checks every file against
# the SHA-256 pinned below, the same trust-on-first-use model as install-tools.sh (ADR 0006).
# The fonts are committed, so builds never contact Google; run this only to re-fetch or update.
#
#   ./scripts/fetch-fonts.sh           download, verify, install
#   ./scripts/fetch-fonts.sh --verify  check the committed files only (no network; used by make check)
#
# Source: Google Fonts' pre-split subsets (latin + latin-ext only; Polish needs latin-ext).
# Updating: change URL + hash together, after checking the new file (see ADR 0009).
set -euo pipefail

cd "$(dirname "$0")/.."
DEST="static/fonts"

# name | sha256 | url
FILES=$(cat <<'EOF'
geist-latin.woff2|19f9c92546aa300c312235e3125af1b81394d8db9a4bc4a425cd5b641d2d54e1|https://fonts.gstatic.com/s/geist/v5/gyByhwUxId8gMEwcGFU.woff2
geist-latin-ext.woff2|824f485b5d26e2f2da3c2b236132ece1bc8e4e43373452950bb0e40548b4313f|https://fonts.gstatic.com/s/geist/v5/gyByhwUxId8gMEwSGFWfOw.woff2
geist-mono-latin.woff2|684ad5b531f81d43c1e8c7038262d5db7cdc1f68006e04d6c7769efa8d33c8cc|https://fonts.gstatic.com/s/geistmono/v6/or3nQ6H-1_WfwkMZI_qYFrcdmg.woff2
geist-mono-latin-ext.woff2|1a189eb997c3e2ece68373e387afaec9e8617424186c4b1ab3cff7c54ba6223b|https://fonts.gstatic.com/s/geistmono/v6/or3nQ6H-1_WfwkMZI_qYFrkdmgPn.woff2
jetbrains-mono-latin.woff2|14425ba9c695763c1547f48a206b7aa60350a33ae23de09f0407877f3fcd89eb|https://fonts.gstatic.com/s/jetbrainsmono/v24/tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTOlOV.woff2
jetbrains-mono-latin-ext.woff2|505dfba8ecbe77e82765f36d317ed7ef4ac42719dc5f4ae68d1c483fd22d0d14|https://fonts.gstatic.com/s/jetbrainsmono/v24/tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTNFOVgaY.woff2
OFL-geist.txt|1781d2806a07d91c4edf4740b88449fab7d0eadad53f7c351b94cd4d4eb8c00f|https://raw.githubusercontent.com/google/fonts/main/ofl/geist/OFL.txt
OFL-geist-mono.txt|1781d2806a07d91c4edf4740b88449fab7d0eadad53f7c351b94cd4d4eb8c00f|https://raw.githubusercontent.com/google/fonts/main/ofl/geistmono/OFL.txt
OFL-jetbrains-mono.txt|b2fe5e8987594e9ffd1d2ca52a2f5d73eb8335243893c5d6254b5ad69269591d|https://raw.githubusercontent.com/google/fonts/main/ofl/jetbrainsmono/OFL.txt
EOF
)

check() { # check <file> <expected-sha256>  -> prints the actual hash, fails on mismatch
  local actual
  actual="$(sha256sum "$1" | cut -d' ' -f1)"
  if [[ "$actual" != "$2" ]]; then
    echo "CHECKSUM MISMATCH: $1" >&2
    echo "  expected (pinned): $2" >&2
    echo "  got:               $actual" >&2
    return 1
  fi
}

if [[ "${1:-}" == "--verify" ]]; then
  while IFS='|' read -r name sha _url; do
    check "$DEST/$name" "$sha"
  done <<< "$FILES"
  echo "fonts OK: $(wc -l <<< "$FILES") files match their pinned SHA-256"
  exit 0
fi

mkdir -p "$DEST"
while IFS='|' read -r name sha url; do
  tmp="$(mktemp)"
  curl -fsSL -o "$tmp" "$url"
  if ! check "$tmp" "$sha"; then rm -f "$tmp"; exit 1; fi
  mv "$tmp" "$DEST/$name"
  chmod 644 "$DEST/$name"
  echo "  sha256 OK: $name"
done <<< "$FILES"
