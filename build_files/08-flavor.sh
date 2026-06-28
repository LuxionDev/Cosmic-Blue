#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

IMAGE_NAME="${IMAGE_NAME:-cosmic-blue}"
IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
AKMODS_FLAVOR="${AKMODS_FLAVOR:-${IMAGE_FLAVOR}}"
UBLUE_IMAGE_TAG="${UBLUE_IMAGE_TAG:-latest}"

echo "IMAGE_NAME=${IMAGE_NAME}"
echo "IMAGE_FLAVOR=${IMAGE_FLAVOR}"
echo "AKMODS_FLAVOR=${AKMODS_FLAVOR}"
echo "UBLUE_IMAGE_TAG=${UBLUE_IMAGE_TAG}"

case "${IMAGE_FLAVOR}" in
    main)
        echo "IMAGE_FLAVOR=main; using vendor-neutral base image path."
        ;;
    nvidia-open)
        echo "IMAGE_FLAVOR=nvidia-open selected."
        echo "NVIDIA flavor payload was applied in 03-install-kernel-akmods.sh."
        echo "No additional flavor-stage changes required."
        ;;
    *)
        echo "Unsupported IMAGE_FLAVOR: ${IMAGE_FLAVOR}" >&2
        exit 1
        ;;
esac

echo "::endgroup::"
