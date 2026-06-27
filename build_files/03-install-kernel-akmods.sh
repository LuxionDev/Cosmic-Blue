#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

IMAGE_NAME="${IMAGE_NAME:-cosmic-blue}"
IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
AKMODS_FLAVOR="${AKMODS_FLAVOR:-main}"
BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-base}"
UBLUE_IMAGE_TAG="${UBLUE_IMAGE_TAG:-latest}"
KERNEL="${KERNEL:-}"

case "${IMAGE_FLAVOR}" in
    main)
        echo "IMAGE_FLAVOR=main; leaving the base image kernel and akmods path unchanged."
        ;;
    nvidia-open)
        if [[ -z "${KERNEL}" ]]; then
            echo "KERNEL must be provided for IMAGE_FLAVOR=nvidia-open." >&2
            exit 1
        fi

        for cmd in jq skopeo tar; do
            command -v "${cmd}" >/dev/null 2>&1 || {
                echo "Missing required command for Bluefin-style akmods path: ${cmd}" >&2
                exit 1
            }
        done

        echo "Bluefin-style nvidia-open path selected for ${IMAGE_NAME}."
        echo "Expected common akmods source: ghcr.io/ublue-os/akmods:${AKMODS_FLAVOR}-$(rpm -E %fedora)-${KERNEL}"
        echo "Expected NVIDIA akmods source: ghcr.io/ublue-os/akmods-nvidia-open:${AKMODS_FLAVOR}-$(rpm -E %fedora)-${KERNEL}"
        echo "Actual akmods container consumption is the next implementation step on this branch." >&2
        exit 1
        ;;
    *)
        echo "Unsupported IMAGE_FLAVOR for kernel/akmods stage: ${IMAGE_FLAVOR}" >&2
        exit 1
        ;;
esac

echo "::endgroup::"
