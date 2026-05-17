#!/usr/bin/env bash
# Apply celestia-steam patches to an upstream Celestia checkout.
#
# Usage: from within the upstream Celestia checkout:
#   ../celestia-steam/scripts/apply-patches.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DIR="${SCRIPT_DIR}/../patches"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "error: must be run from inside a git checkout of Celestia" >&2
    exit 1
fi

shopt -s nullglob
patches=("${PATCH_DIR}"/*.patch)
if [[ ${#patches[@]} -eq 0 ]]; then
    echo "no patches to apply"
    exit 0
fi

for patch in "${patches[@]}"; do
    echo "applying $(basename "$patch")"
    git apply --index "$patch"
done

echo "applied ${#patches[@]} patch(es)"
