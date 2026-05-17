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

detect_gpu_profile() {
    if rpm -q akmod-nvidia-open >/dev/null 2>&1; then
        echo "nvidia-open"
    else
        echo "none"
    fi
}

GPU_PROFILE="${GPU_PROFILE:-$(detect_gpu_profile)}"

command -v starship >/dev/null 2>&1
starship --version >/dev/null 2>&1
systemctl is-enabled podman.socket >/dev/null
systemctl is-enabled cosmic-greeter.service >/dev/null

test -f /usr/share/wayland-sessions/cosmic.desktop
rpm -q xdg-desktop-portal-cosmic >/dev/null 2>&1

case "${GPU_PROFILE}" in
    none)
        mapfile -t NVIDIA_LINES < <(grep -Ev '^\s*($|#)' packages/nvidia-open.txt)
        for raw in "${NVIDIA_LINES[@]}"; do
            pkg="${raw}"
            rpm -q "${pkg}" >/dev/null 2>&1 && { echo "Unexpected NVIDIA package present: ${pkg}" >&2; exit 1; }
        done

        command -v nvidia-smi >/dev/null 2>&1 && { echo "Unexpected NVIDIA userspace artifact present: nvidia-smi" >&2; exit 1; }
        ;;
    nvidia-open)
        mapfile -t NVIDIA_LINES < <(grep -Ev '^\s*($|#)' packages/nvidia-open.txt)
        for raw in "${NVIDIA_LINES[@]}"; do
            pkg="${raw}"
            rpm -q "${pkg}" >/dev/null 2>&1 || { echo "Required NVIDIA package missing: ${pkg}" >&2; exit 1; }
        done

        command -v nvidia-smi >/dev/null 2>&1 || { echo "Expected NVIDIA userspace artifact missing: nvidia-smi" >&2; exit 1; }
        ;;
    *)
        echo "Unsupported GPU_PROFILE for smoke test: ${GPU_PROFILE}" >&2
        exit 1
        ;;
esac

echo "Smoke test passed."
