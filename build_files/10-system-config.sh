#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Keep host configuration minimal and explicit.
systemctl enable podman.socket

# Cosmetic branding: keep compatibility fields (like ID) unchanged.
OS_RELEASE="/usr/lib/os-release"

set_os_release_field() {
    local key="$1"
    local value="$2"
    if grep -q "^${key}=" "${OS_RELEASE}"; then
        sed -i "s|^${key}=.*|${key}=\"${value}\"|" "${OS_RELEASE}"
    else
        echo "${key}=\"${value}\"" >> "${OS_RELEASE}"
    fi
}

set_os_release_field "NAME" "Cosmic-Blue"
set_os_release_field "PRETTY_NAME" "Cosmic-Blue"
set_os_release_field "VARIANT" "Atomic"
set_os_release_field "VARIANT_ID" "atomic"

echo "::endgroup::"
