#!/bin/bash

set -ouex pipefail

PACKAGE_FILE="/ctx/packages/base.txt"

if [[ ! -f "${PACKAGE_FILE}" ]]; then
    echo "Missing packages list: ${PACKAGE_FILE}" >&2
    exit 1
fi

mapfile -t PKGS < <(grep -Ev '^\s*($|#)' "${PACKAGE_FILE}")

if [[ "${#PKGS[@]}" -gt 0 ]]; then
    dnf5 install -y "${PKGS[@]}"
fi
