#!/bin/bash
# Sets zsh as the login shell (asks for the password once).
set -euo pipefail
current="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
if [[ "$current" != "/bin/zsh" ]]; then
    echo "Login shell is $current - switching to /bin/zsh."
    chsh -s /bin/zsh
fi
