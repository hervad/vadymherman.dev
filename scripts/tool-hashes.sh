#!/usr/bin/env bash
# Prints the SHA-256 lines for versions.env, read from each project's official checksum files.
# Use after bumping HUGO_VERSION or PAGEFIND_VERSION: run `make tool-hashes`, paste the output
# into versions.env, review the diff, commit. Nothing is installed or changed by this script.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source versions.env

hugo_sums="$(curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_checksums.txt")"
hugo_hash() { awk -v f="hugo_${HUGO_VERSION}_linux-$1.tar.gz" '$2 == f { print $1 }' <<<"$hugo_sums"; }

pf_hash() {
  curl -fsSL "https://github.com/Pagefind/pagefind/releases/download/v${PAGEFIND_VERSION}/pagefind-v${PAGEFIND_VERSION}-$1-unknown-linux-musl.tar.gz.sha256" | cut -d' ' -f1
}

echo "HUGO_SHA256_AMD64=$(hugo_hash amd64)"
echo "HUGO_SHA256_ARM64=$(hugo_hash arm64)"
echo "PAGEFIND_SHA256_X86_64=$(pf_hash x86_64)"
echo "PAGEFIND_SHA256_AARCH64=$(pf_hash aarch64)"
