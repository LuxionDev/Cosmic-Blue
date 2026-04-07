#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Keep stage ordering explicit and easy to review.
/usr/bin/bash /ctx/04-packages.sh
/usr/bin/bash /ctx/05-override-install.sh