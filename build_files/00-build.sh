#!/bin/bash

set -ouex pipefail

# Keep stage ordering explicit and easy to review.
# this installs a package from fedora repos
dnf5 install -y tmux