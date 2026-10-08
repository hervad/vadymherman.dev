#!/usr/bin/env bash
# Downloads the pinned Hugo (and later Pagefind) binaries into ./.bin
# Why not `dnf install hugo`? Fedora's package can lag behind or jump ahead of the
# version CI uses. Pinning one version everywhere means "works on my machine" = "works in CI".
# Every archive is checked against the SHA-256 pinned in versions.env before it is unpacked
# (ADR 0006), so a corrupted or swapped download never runs.
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source versions.env

BIN_DIR=".bin"
mkdir -p "$BIN_DIR"

arch="$(uname -m)"
case "$arch" in
  x86_64)  hugo_arch="amd64"; pf_arch="x86_64"
           hugo_sha="$HUGO_SHA256_AMD64"; pf_sha="$PAGEFIND_SHA256_X86_64" ;;
  aarch64) hugo_arch="arm64"; pf_arch="aarch64"
           hugo_sha="$HUGO_SHA256_ARM64"; pf_sha="$PAGEFIND_SHA256_AARCH64" ;;
  *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
esac

# install_verified <url> <expected-sha256> <file-inside-archive>
# Download to a temp file, refuse it unless the hash matches, then unpack one file into .bin
install_verified() {
  local url="$1" expected="$2" member="$3" tmp actual
  tmp="$(mktemp)"
  curl -fsSL -o "$tmp" "$url"
  actual="$(sha256sum "$tmp" | cut -d' ' -f1)"
  if [[ "$actual" != "$expected" ]]; then
    rm -f "$tmp"
    echo "CHECKSUM MISMATCH for $url" >&2
    echo "  expected (versions.env): $expected" >&2
    echo "  got (downloaded file):   $actual" >&2
    exit 1
  fi
  echo "  sha256 OK: $actual"
  tar -xzf "$tmp" -C "$BIN_DIR" "$member"
  rm -f "$tmp"
}

if [[ -x "$BIN_DIR/hugo" ]] && "$BIN_DIR/hugo" version | grep -q "v${HUGO_VERSION}-"; then
  echo "hugo v${HUGO_VERSION} already installed"
else
  echo "Installing hugo v${HUGO_VERSION}..."
  install_verified \
    "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-${hugo_arch}.tar.gz" \
    "$hugo_sha" hugo
fi

if [[ "${1:-}" == "--with-pagefind" ]]; then
  echo "Installing pagefind v${PAGEFIND_VERSION}..."
  install_verified \
    "https://github.com/Pagefind/pagefind/releases/download/v${PAGEFIND_VERSION}/pagefind-v${PAGEFIND_VERSION}-${pf_arch}-unknown-linux-musl.tar.gz" \
    "$pf_sha" pagefind
fi

"$BIN_DIR/hugo" version
