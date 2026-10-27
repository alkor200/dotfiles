#!/usr/bin/env bash
# Bootstrap for a fresh machine: curl -fsSL https://raw.githubusercontent.com/alkor200/dotfiles/main/install.sh | bash
# On Linux, run it once as your normal user and once more as/via root (sudo bash) to set up both.
set -euo pipefail

REPO="${DOTFILES_REPO:-alkor200}"   # GitHub user or full repo URL
OS="$(uname -s)"

case "$OS" in
Darwin)
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

    # 3) chezmoi (the rest of the packages come from the Brewfile via chezmoi apply)
    brew install chezmoi
    ;;

Linux)
    sudo_cmd=""
    [[ "$(id -u)" -eq 0 ]] || sudo_cmd="sudo"

    # 1) Bare minimum needed before chezmoi can take over (full list in apt-packages.txt)
    echo "==> Installing base packages via apt"
    $sudo_cmd apt-get update
    $sudo_cmd apt-get install -y git curl zsh

    # 2) chezmoi - not packaged in Debian/Ubuntu, use the official installer (no linuxbrew)
    bin_dir="$HOME/.local/bin"
    [[ "$(id -u)" -eq 0 ]] && bin_dir="/usr/local/bin"
    mkdir -p "$bin_dir"
    if ! command -v chezmoi >/dev/null 2>&1; then
        echo "==> Installing chezmoi to $bin_dir"
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$bin_dir"
    fi
    export PATH="$bin_dir:$PATH"
    ;;

*)
    echo "Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

# Apply chezmoi + dotfiles (installs the rest via Brewfile / apt-packages.txt)
chezmoi init --apply "$REPO"
