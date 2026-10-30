#!/usr/bin/env bash
# Double-click in Finder to install the last build after quitting T3 Code.
"$(dirname "$0")/install.sh"
echo
read -r -p "Press Enter to close..."
