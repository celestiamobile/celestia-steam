#!/usr/bin/env bash
# Apply celestia-steam patches to the celestia/ submodule.
#
# Usage (from celestia-steam root):
#   scripts/apply-patches.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PATCH_DIR="${REPO_ROOT}/patches"
CELESTIA_DIR="${REPO_ROOT}/celestia"

if [[ ! -e "${CELESTIA_DIR}/.git" ]]; then
    echo "error: ${CELESTIA_DIR} is not a git checkout — did you forget" >&2
    echo "       'git submodule update --init --recursive'?" >&2
    exit 1
fi

shopt -s nullglob
patches=("${PATCH_DIR}"/*.patch)
if [[ ${#patches[@]} -eq 0 ]]; then
    echo "no patches to apply"
    exit 0
fi

cd "${CELESTIA_DIR}"
for patch in "${patches[@]}"; do
    echo "applying $(basename "$patch")"
    git apply --index "$patch"
done

echo "applied ${#patches[@]} patch(es)"
