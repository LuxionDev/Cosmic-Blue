#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

readarray -t COSMIC_PACKAGES < <(grep -Ev '^\s*($|#)' /ctx/packages/cosmic.txt)

echo "Installing ${#COSMIC_PACKAGES[@]} COSMIC desktop-core packages..."
dnf5 -y install "${COSMIC_PACKAGES[@]}"

echo "::endgroup::"
