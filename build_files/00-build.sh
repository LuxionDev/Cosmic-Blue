#!/bin/bash

set -ouex pipefail

# Keep stage ordering explicit and easy to review.
/usr/bin/bash /ctx/04-packages.sh