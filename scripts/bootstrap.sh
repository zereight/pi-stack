#!/usr/bin/env bash
set -euo pipefail

PISTACK_GIT_REF="${PISTACK_GIT_REF:-main}"
PISTACK_INSTALL_SOURCE="${PISTACK_INSTALL_SOURCE:-git:github.com/zereight/pi-stack@${PISTACK_GIT_REF}}"
INSTALL_LOCAL=0

usage() {
  cat <<'EOF'
Usage: ./scripts/bootstrap.sh [options]

One-shot install: pi package + pstack skills sync. No Cursor IDE required.

Options:
  --local          pi install . from this repo checkout (for development)
  --ref <branch>   Git ref for remote install (default: main)
  -h, --help       Show this help

Examples:
  curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash

  git clone https://github.com/zereight/pi-stack.git && cd pi-stack
  ./scripts/bootstrap.sh --local
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)
      INSTALL_LOCAL=1
      shift
      ;;
    --ref)
      PISTACK_GIT_REF="${2:?missing value for --ref}"
      PISTACK_INSTALL_SOURCE="git:github.com/zereight/pi-stack@${PISTACK_GIT_REF}"
      shift 2
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

if ! command -v pi >/dev/null 2>&1; then
  echo "error: pi is not on PATH. Install from https://pi.dev/" >&2
  exit 1
fi

if [[ "${INSTALL_LOCAL}" -eq 1 ]]; then
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  echo "Installing pistack from local checkout: ${REPO_ROOT}"
  pi install "${REPO_ROOT}"
  PKG_DIR="${REPO_ROOT}"
else
  echo "Installing pistack: ${PISTACK_INSTALL_SOURCE}"
  pi install "${PISTACK_INSTALL_SOURCE}"
  PKG_DIR="${HOME}/.pi/agent/git/github.com/zereight/pi-stack"
  if [[ ! -d "${PKG_DIR}" ]]; then
    echo "error: expected clone at ${PKG_DIR}. Run: pi list" >&2
    exit 1
  fi
fi

"${PKG_DIR}/scripts/sync-pistack-skills.sh"

cat <<EOF

pistack installed.

Next:
  1. Set "enableSkillCommands": true in ~/.pi/agent/settings.json
  2. Restart pi (or /reload)
  3. Run /pistack to verify skills path

Example:
  /poteto-mode repro and fix the scroll drift bug in this pr
EOF
