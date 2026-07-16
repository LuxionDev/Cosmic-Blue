#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

IMAGE_NAME="${IMAGE_NAME:-cosmic-blue}"
IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
AKMODS_FLAVOR="${AKMODS_FLAVOR:-main}"
BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-base}"
UBLUE_IMAGE_TAG="${UBLUE_IMAGE_TAG:-latest}"
KERNEL="${KERNEL:-}"

extract_rpm_layer() {
    local image_dir="$1"
    local target_dir="$2"
    local layer_digest
    local tmp_extract

    layer_digest=$(jq -r '.layers[].digest' < "${image_dir}/manifest.json" | cut -d : -f 2)
    tmp_extract=$(mktemp -d /tmp/akmods-layer.XXXXXX)
    tar -xvzf "${image_dir}/${layer_digest}" -C "${tmp_extract}"
    mkdir -p "${target_dir}"
    cp -a "${tmp_extract}/." "${target_dir}/"
    rm -rf "${tmp_extract}"
}

case "${IMAGE_FLAVOR}" in
    main)
        echo "IMAGE_FLAVOR=main; leaving the base image kernel and akmods path unchanged."
        ;;
    nvidia-open)
        if [[ -z "${KERNEL}" ]]; then
            echo "KERNEL must be provided for IMAGE_FLAVOR=nvidia-open." >&2
            exit 1
        fi

        for cmd in dnf5 jq rpm skopeo tar; do
            command -v "${cmd}" >/dev/null 2>&1 || {
                echo "Missing required command for Bluefin-style akmods path: ${cmd}" >&2
                exit 1
            }
        done

        for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do
            rpm --erase "${pkg}" --nodeps || true
        done

        rm -rf /tmp/akmods /tmp/akmods-rpms /tmp/kernel-rpms

        skopeo copy --retry-times 3 "docker://ghcr.io/ublue-os/akmods:${AKMODS_FLAVOR}-$(rpm -E %fedora)-${KERNEL}" dir:/tmp/akmods
        extract_rpm_layer /tmp/akmods /tmp

        dnf5 -y install \
            /tmp/kernel-rpms/kernel-[0-9]*.rpm \
            /tmp/kernel-rpms/kernel-core-*.rpm \
            /tmp/kernel-rpms/kernel-modules-*.rpm

        dnf5 -y install \
            /tmp/kernel-rpms/kernel-devel-*.rpm

        dnf5 versionlock add kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra

        if [[ -f /etc/yum.repos.d/_copr_ublue-os-akmods.repo ]]; then
            sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
        fi

        dnf5 -y install \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

        skopeo copy --retry-times 3 "docker://ghcr.io/ublue-os/akmods-nvidia-open:${AKMODS_FLAVOR}-$(rpm -E %fedora)-${KERNEL}" dir:/tmp/akmods-rpms
        extract_rpm_layer /tmp/akmods-rpms /tmp/akmods-rpms

        IMAGE_NAME="${BASE_IMAGE_NAME}" AKMODNV_PATH="/tmp/akmods-rpms/rpms" MULTILIB=0 /tmp/akmods-rpms/rpms/ublue-os/nvidia-install.sh

        rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json
        ln -sf libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so
        tee /usr/lib/bootc/kargs.d/00-nvidia.toml <<EOF
kargs = ["rd.driver.blacklist=nouveau", "modprobe.blacklist=nouveau", "nvidia-drm.modeset=1", "initcall_blacklist=simpledrm_platform_driver_init"]
EOF

        dnf5 -y remove rpmfusion-free-release rpmfusion-nonfree-release
        ;;
    *)
        echo "Unsupported IMAGE_FLAVOR for kernel/akmods stage: ${IMAGE_FLAVOR}" >&2
        exit 1
        ;;
esac

echo "::endgroup::"
