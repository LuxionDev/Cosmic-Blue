#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

GPU_PROFILE="${GPU_PROFILE:-none}"

case "${GPU_PROFILE}" in
    none)
        echo "GPU_PROFILE=none; skipping vendor-specific GPU packages."
        ;;
    nvidia-open)
        readarray -t NVIDIA_PACKAGES < <(grep -Ev '^\s*($|#)' /ctx/packages/nvidia-open.txt)

        echo "Installing ${#NVIDIA_PACKAGES[@]} NVIDIA profile packages..."
        dnf5 -y install "${NVIDIA_PACKAGES[@]}"
        ;;
    *)
        echo "Unsupported GPU_PROFILE: ${GPU_PROFILE}" >&2
        exit 1
        ;;
esac

echo "::endgroup::"
