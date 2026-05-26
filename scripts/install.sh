#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXTENSION_SRC="${REPO_ROOT}/extensions/pistack"
EXTENSION_DEST="${HOME}/.pi/agent/extensions/pistack"
SKIP_SKILLS=0

usage() {
  cat <<'EOF'
Usage: ./scripts/install.sh [options]

Install pistack into ~/.pi/agent/extensions/pistack and sync pstack skills.

Options:
  --skip-skills   Do not run sync-pistack-skills.sh (use PISTACK_SKILLS_DIR or cache fallback)
  -h, --help      Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-skills)
      SKIP_SKILLS=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

mkdir -p "${HOME}/.pi/agent/extensions"
ln -sfn "${EXTENSION_SRC}" "${EXTENSION_DEST}"
echo "pistack extension → ${EXTENSION_DEST} -> ${EXTENSION_SRC}"

if [[ "${SKIP_SKILLS}" -eq 0 ]]; then
  "${REPO_ROOT}/scripts/sync-pistack-skills.sh"
else
  echo "skipped skills sync (--skip-skills)"
  echo "  set PISTACK_SKILLS_DIR or run ./scripts/sync-pistack-skills.sh later"
fi

cat <<EOF

Installed. Next steps:
  1. Ensure ~/.pi/agent/settings.json has "enableSkillCommands": true
  2. Restart pi (or run /reload)
  3. Run /pistack inside pi to verify the skills path

Example:
  /poteto-mode repro and fix the scroll drift bug in this pr
EOF
