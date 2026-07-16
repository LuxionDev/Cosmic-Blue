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

detect_image_flavor() {
    if command -v nvidia-smi >/dev/null 2>&1; then
        echo "nvidia-open"
    else
        echo "main"
    fi
}

IMAGE_FLAVOR="${IMAGE_FLAVOR:-$(detect_image_flavor)}"

command -v starship >/dev/null 2>&1
starship --version >/dev/null 2>&1
systemctl is-enabled podman.socket >/dev/null
systemctl is-enabled cosmic-greeter.service >/dev/null

test -f /usr/share/wayland-sessions/cosmic.desktop
rpm -q xdg-desktop-portal-cosmic >/dev/null 2>&1

case "${IMAGE_FLAVOR}" in
    main)
        command -v nvidia-smi >/dev/null 2>&1 && { echo "Unexpected NVIDIA userspace artifact present: nvidia-smi" >&2; exit 1; }
        ;;
    nvidia-open)
        NVIDIA_PACKAGES=(
            libnvidia-container-tools
            kmod-nvidia
            nvidia-driver-cuda
        )

        for pkg in "${NVIDIA_PACKAGES[@]}"; do
            rpm -q "${pkg}" >/dev/null 2>&1 || { echo "Expected NVIDIA package missing: ${pkg}" >&2; exit 1; }
        done

        command -v nvidia-smi >/dev/null 2>&1 || { echo "Expected NVIDIA userspace artifact missing: nvidia-smi" >&2; exit 1; }
        ;;
    *)
        echo "Unsupported IMAGE_FLAVOR for smoke test: ${IMAGE_FLAVOR}" >&2
        exit 1
        ;;
esac

echo "Smoke test passed."
