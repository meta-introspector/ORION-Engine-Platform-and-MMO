#!/usr/bin/env bash
# merge-projects.sh — Prepare a merged review workspace for two Aristotle projects.
#
# Usage: ./merge-projects.sh
#   Creates a single merged source tree under merged-projects/merged/ by
#   copying both project source trees, flagging conflicts for review.
#
# The two tracked projects:
#   project-17da0589   : 17da0589-2bfc-44c4-8169-dbdb61676da2 (newer, active)
#   project-0f9b0981   : 0f9b0981-20e1-40ac-8da1-7ea508d9520c (older)
#
# Each project lives under merged-projects/project-<ID>/sources/lean as a symlink
# to the original Aristotle download. This script copies them into a flat merged
# tree so reviewers can diff, compare, and merge without touching the originals.
#
# Version 1.0

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

PROJECT_1_DIR="${BASE_DIR}/project-17da0589/sources/lean"
PROJECT_2_DIR="${BASE_DIR}/project-0f9b0981/sources/lean"

# Validate the two project directories exist.
for proj in "${PROJECT_1_DIR}" "${PROJECT_2_DIR}"; do
    if [ ! -d "${proj}" ]; then
        echo "ERROR: Missing project source dir ${proj}"
        exit 1
    fi
done

MERGED_OUT="${BASE_DIR}/merged"

# Clean a previous merged output if present.
if [ -d "${MERGED_OUT}" ]; then
    echo "Removing existing merged output: ${MERGED_OUT}"
    rm -rf "${MERGED_OUT}"
fi
mkdir -p "${MERGED_OUT}"

echo "=== Merging project sources for review ==="
echo "  Source 1 (newer): project-17da0589"
echo "  Source 2 (older): project-0f9b0981"

# Stage 1: copy the entire newer tree into the merged location.
echo "[1/4] Copying project-17da0589 source tree..."
cp -a --no-preserve=mode "${PROJECT_1_DIR}/." "${MERGED_OUT}/"

# Stage 2: copy the older tree, flagging duplicates into a conflict report.
echo "[2/4] Copying project-0f9b0981 source tree and flagging conflicts..."
CONFLICTS="${BASE_DIR}/MERGED_CONFLICTS.md"
: > "${CONFLICTS}"
printf "# Merge conflicts between project-0f9b0981 (older) and project-17da0589 (newer)\n\n" >> "${CONFLICTS}"
printf "| Path | Type in branch-1 (newer) | Type in branch-2 (older) | Resolution | Notes |\n" >> "${CONFLICTS}"
printf "|------|--------------------------|--------------------------|------------|-------|\n" >> "${CONFLICTS}"

find "${PROJECT_2_DIR}" -mindepth 1 -maxdepth 1 | sort | while IFS= read -r item; do
    rel="${item#${PROJECT_2_DIR}/}"
    if [ -e "${MERGED_OUT}/${rel}" ]; then
        t1=""
        t2=""
        if [ -d "${MERGED_OUT}/${rel}" ]; then t1="dir"; fi
        if [ -f "${MERGED_OUT}/${rel}" ]; then t1="${t1:+$t1, }file"; fi
        if [ -d "${item}" ]; then t2="dir"; fi
        if [ -f "${item}" ]; then t2="${t2:+$t2, }file"; fi
        printf "| `%s` | %s | %s | PENDING | Review which content to keep |\n" "${rel}" "${t1}" "${t2}" >> "${CONFLICTS}"
    else
        cp -a --no-preserve=mode "${item}" "${MERGED_OUT}/"
    fi
done

echo "[3/4] Writing conflict report: ${CONFLICTS}"

# Stage 4: summarize.
echo "[4/4] Merge complete."
echo "  Merged tree: ${MERGED_OUT}"
echo "  Conflict report: ${CONFLICTS}"
echo ""
echo "Review steps:"
echo "  1. Read ${BASE_DIR}/PROJECT-COMPARISON.md"
echo "  2. Resolve entries in ${CONFLICTS}"
echo "  3. Choose final files in ${MERGED_OUT}/"
echo "  4. Re-deploy with deploy-orion.sh <project-id> --build when ready"