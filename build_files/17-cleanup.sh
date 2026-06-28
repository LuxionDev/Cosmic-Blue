#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

dnf5 clean all
rm -rf /var/cache/dnf

# Remove transient state created during package transactions and scriptlets.
rm -rf /run/dnf /run/selinux-policy

# Drop build-time package manager and container cache state from the image.
rm -rf /var/lib/dnf
rm -rf /var/lib/containers

# Remove generated files that should not be baked into the image.
rm -f /var/lib/xkb/README.compiled
rm -rf /var/lib/greetd/.config/systemd/user

echo "::endgroup::"
