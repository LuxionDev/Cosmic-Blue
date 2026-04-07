#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# External binary overrides/downloads live here.
# Keep this stage small and explicit.

TMPDIR="$(mktemp -d /tmp/starship.XXXXXX)"
trap 'rm -rf "${TMPDIR}"' EXIT

STARSHIP_URL="https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"
ARCHIVE_PATH="${TMPDIR}/starship.tar.gz"

if command -v ghcurl >/dev/null 2>&1; then
    ghcurl "${STARSHIP_URL}" --retry 3 -o "${ARCHIVE_PATH}"
else
    curl -fL --retry 3 --retry-delay 2 -o "${ARCHIVE_PATH}" "${STARSHIP_URL}"
fi

tar -xzf "${ARCHIVE_PATH}" -C "${TMPDIR}"
install -c -m 0755 "${TMPDIR}/starship" /usr/bin/starship

echo "::endgroup::"
