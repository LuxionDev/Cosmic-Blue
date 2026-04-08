#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

dnf5 clean all
rm -rf /var/cache/dnf

echo "::endgroup::"
