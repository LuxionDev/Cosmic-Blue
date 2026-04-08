#!/usr/bin/bash

set -euo pipefail

mapfile -t BASE_LINES < <(grep -Ev '^\s*($|#)' packages/base.txt)
for raw in "${BASE_LINES[@]}"; do
    pkg="${raw}"
    rpm -q "${pkg}" >/dev/null 2>&1 || { echo "Required package missing: ${pkg}" >&2; exit 1; }
done

mapfile -t COSMIC_LINES < <(grep -Ev '^\s*($|#)' packages/cosmic.txt)
for raw in "${COSMIC_LINES[@]}"; do
    pkg="${raw}"
    rpm -q "${pkg}" >/dev/null 2>&1 || { echo "Required COSMIC package missing: ${pkg}" >&2; exit 1; }
done

command -v starship >/dev/null 2>&1
starship --version >/dev/null 2>&1
systemctl is-enabled podman.socket >/dev/null

test -f /usr/share/wayland-sessions/cosmic.desktop
rpm -q xdg-desktop-portal-cosmic >/dev/null 2>&1

echo "Smoke test passed."
