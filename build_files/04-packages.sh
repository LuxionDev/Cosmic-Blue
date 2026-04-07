#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# All DNF-related operations should be done here whenever possible.
# Cosmic-Blue keeps package intent in /ctx/packages/*.txt, then installs in bulk.

readarray -t FEDORA_PACKAGES < <(grep -Ev '^\s*($|#)' /ctx/packages/base.txt)

echo "Installing ${#FEDORA_PACKAGES[@]} packages from Fedora repos..."
dnf5 -y install "${FEDORA_PACKAGES[@]}"

echo "::endgroup::"
