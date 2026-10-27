#!/usr/bin/env bash
# Bootstrap for a fresh Mac: curl -fsSL https://raw.githubusercontent.com/<YOUR-USER>/dotfiles/main/install.sh | bash
set -euo pipefail

REPO="${DOTFILES_REPO:-<YOUR-USER>}"   # GitHub user or full repo URL

[[ "$(uname -s)" == "Darwin" ]] || { echo "This script is meant for macOS." >&2; exit 1; }

# 1) Xcode Command Line Tools (git, clang)
if ! xcode-select -p >/dev/null 2>&1; then
    echo "==> Installing Xcode Command Line Tools - confirm the dialog, then run this script again."
    xcode-select --install
    exit 0
fi

# 2) Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "==> Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$b" ]] && eval "$("$b" shellenv)" && break
done

# 3) Apply chezmoi + dotfiles (installs the rest via Brewfile)
brew install chezmoi
chezmoi init --apply "$REPO"

echo
echo "==> Done. Still open:"
echo "    - Install Alacritty manually if needed (Homebrew cask is disabled, not notarized)"
echo "    - Add local settings/secrets to ~/.zshrc.local"
echo "    - Open a new terminal"
