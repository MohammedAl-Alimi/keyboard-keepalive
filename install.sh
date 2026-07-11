#!/bin/bash
# One-shot installer for keyboard-keepalive.
# Run from inside the cloned repo:  ./install.sh
set -e

LABEL="com.local.keyboard-keepalive"
SCRIPT_SRC="keyboard-keepalive.sh"
PLIST_SRC="${LABEL}.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/${LABEL}.plist"

# 1. Script -> home, executable
cp "$SCRIPT_SRC" "$HOME/keyboard-keepalive.sh"
chmod +x "$HOME/keyboard-keepalive.sh"

# 2. Patch username and install plist
mkdir -p "$HOME/Library/LaunchAgents"
sed "s/REPLACE_WITH_YOUR_USERNAME/$(whoami)/g" "$PLIST_SRC" > "$PLIST_DEST"

# 3. Reload cleanly (ignore error if not already loaded)
launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DEST"

echo "Installed and loaded. Check status with:"
echo "  launchctl print gui/$(id -u)/${LABEL} | grep -E 'state|pid'"
echo
echo "Note: grant Accessibility to /bin/bash the first time a tap fires,"
echo "under System Settings > Privacy & Security > Accessibility."
