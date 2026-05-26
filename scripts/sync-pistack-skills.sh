#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${REPO_ROOT}/extensions/pistack/skills"
PSTACK_CACHE_ROOT="${HOME}/.pi/agent/cache/pstack-plugins"
PSTACK_SKILLS_DIR="${PSTACK_CACHE_ROOT}/pstack/skills"
PISTACK_PLUGINS_REPO="${PISTACK_PLUGINS_REPO:-https://github.com/cursor/plugins.git}"
PISTACK_PLUGINS_REF="${PISTACK_PLUGINS_REF:-main}"

usage() {
  cat <<'EOF'
Usage: ./scripts/sync-pistack-skills.sh

Symlink extensions/pistack/skills to pstack SKILL.md files.

Resolution order:
  1. PISTACK_SOURCE_SKILLS (explicit path)
  2. ~/.pi/agent/cache/pstack-plugins/pstack/skills (sparse clone cache)
  3. Sparse fetch from https://github.com/cursor/plugins (pstack/skills only)

Requires git and network on first run unless PISTACK_SOURCE_SKILLS is set.

Override:
  PISTACK_SOURCE_SKILLS=/path/to/skills ./scripts/sync-pistack-skills.sh
  PISTACK_PLUGINS_REF=v1.2.3 ./scripts/sync-pistack-skills.sh
  PISTACK_SKIP_FETCH=1   # offline: use cache or PISTACK_SOURCE_SKILLS only
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

skills_dir_is_valid() {
  [[ -n "${1:-}" && -f "${1}/how/SKILL.md" ]]
}

fetch_skills_from_github() {
  if [[ "${PISTACK_SKIP_FETCH:-}" == "1" ]]; then
    return 1
  fi

  if skills_dir_is_valid "${PSTACK_SKILLS_DIR}"; then
    printf '%s\n' "${PSTACK_SKILLS_DIR}"
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "error: git is required to fetch pstack skills from GitHub." >&2
    return 1
  fi

  echo "fetching pstack/skills from ${PISTACK_PLUGINS_REPO} (${PISTACK_PLUGINS_REF})..." >&2
  mkdir -p "$(dirname "${PSTACK_CACHE_ROOT}")"
  rm -rf "${PSTACK_CACHE_ROOT}"
  git clone --depth 1 --filter=blob:none --sparse \
    --branch "${PISTACK_PLUGINS_REF}" \
    "${PISTACK_PLUGINS_REPO}" "${PSTACK_CACHE_ROOT}"
  git -C "${PSTACK_CACHE_ROOT}" sparse-checkout set pstack/skills

  if ! skills_dir_is_valid "${PSTACK_SKILLS_DIR}"; then
    echo "error: GitHub fetch did not produce ${PSTACK_SKILLS_DIR}/how/SKILL.md" >&2
    return 1
  fi

  printf '%s\n' "${PSTACK_SKILLS_DIR}"
}

SOURCE="${PISTACK_SOURCE_SKILLS:-}"
if [[ -z "${SOURCE}" ]]; then
  SOURCE="$(fetch_skills_from_github || true)"
fi

if ! skills_dir_is_valid "${SOURCE}"; then
  echo "error: pstack skills not found." >&2
  echo "  Set PISTACK_SOURCE_SKILLS=/path/to/pstack/skills" >&2
  echo "  Or ensure git + network for GitHub fetch (cursor/plugins pstack/skills)" >&2
  exit 1
fi

mkdir -p "$(dirname "${TARGET}")"
if [[ -L "${TARGET}" || -e "${TARGET}" ]]; then
  rm -rf "${TARGET}"
fi
ln -s "${SOURCE}" "${TARGET}"
echo "pistack skills → ${TARGET} -> ${SOURCE}"
