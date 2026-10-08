#!/usr/bin/env bash
# Downloads the pinned Hugo (and later Pagefind) binaries into ./.bin
# Why not `dnf install hugo`? Fedora's package can lag behind or jump ahead of the
# version CI uses. Pinning one version everywhere means "works on my machine" = "works in CI".
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source versions.env

BIN_DIR=".bin"
mkdir -p "$BIN_DIR"

arch="$(uname -m)"
case "$arch" in
  x86_64)  hugo_arch="amd64"; pf_arch="x86_64" ;;
  aarch64) hugo_arch="arm64"; pf_arch="aarch64" ;;
  *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
esac

if [[ -x "$BIN_DIR/hugo" ]] && "$BIN_DIR/hugo" version | grep -q "v${HUGO_VERSION}-"; then
  echo "hugo v${HUGO_VERSION} already installed"
else
  echo "Installing hugo v${HUGO_VERSION}..."
  url="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-${hugo_arch}.tar.gz"
  curl -fsSL "$url" | tar -xz -C "$BIN_DIR" hugo
fi

if [[ "${1:-}" == "--with-pagefind" ]]; then
  echo "Installing pagefind v${PAGEFIND_VERSION}..."
  url="https://github.com/Pagefind/pagefind/releases/download/v${PAGEFIND_VERSION}/pagefind-v${PAGEFIND_VERSION}-${pf_arch}-unknown-linux-musl.tar.gz"
  curl -fsSL "$url" | tar -xz -C "$BIN_DIR" pagefind
fi

"$BIN_DIR/hugo" version
