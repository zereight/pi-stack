#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${REPO_ROOT}/extensions/pistack/skills"
CACHE_ROOT="${HOME}/.cursor/plugins/cache/cursor-public/pstack"

usage() {
  cat <<'EOF'
Usage: ./scripts/sync-pistack-skills.sh

Symlink extensions/pistack/skills to the newest Cursor pstack plugin cache.

Requires pstack installed in Cursor once (/add-plugin pstack) so the cache exists.

Override source:
  PISTACK_SOURCE_SKILLS=/path/to/skills ./scripts/sync-pistack-skills.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

resolve_latest_cache_skills() {
  local version_dir skills_dir
  if [[ ! -d "${CACHE_ROOT}" ]]; then
    return 1
  fi
  while IFS= read -r version_dir; do
    skills_dir="${version_dir}/skills"
    if [[ -f "${skills_dir}/how/SKILL.md" ]]; then
      printf '%s\n' "${skills_dir}"
      return 0
    fi
  done < <(find "${CACHE_ROOT}" -mindepth 1 -maxdepth 1 -type d | sort)
  return 1
}

SOURCE="${PISTACK_SOURCE_SKILLS:-}"
if [[ -z "${SOURCE}" ]]; then
  SOURCE="$(resolve_latest_cache_skills || true)"
fi

if [[ -z "${SOURCE}" || ! -f "${SOURCE}/how/SKILL.md" ]]; then
  echo "error: pstack skills not found." >&2
  echo "  Install in Cursor: /add-plugin pstack" >&2
  echo "  Or set PISTACK_SOURCE_SKILLS=/path/to/pstack/skills" >&2
  exit 1
fi

mkdir -p "$(dirname "${TARGET}")"
if [[ -L "${TARGET}" || -e "${TARGET}" ]]; then
  rm -rf "${TARGET}"
fi
ln -s "${SOURCE}" "${TARGET}"
echo "pistack skills → ${TARGET} -> ${SOURCE}"
