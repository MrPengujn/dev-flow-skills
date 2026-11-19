#!/usr/bin/env bash
# Installs the dev-flow skills for Claude Code.
#   ./install.sh                      personal skills (~/.claude/skills)
#   ./install.sh --project <dir>      project skills (<dir>/.claude/skills)
#   --without-review                  leave out both review skills
#   --without-security                leave out the security review skill
#   --force                           overwrite skills that are already installed
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.claude/skills"; force=0
skills=(dev-flow dev-plan dev-implement dev-review-logic dev-review-security)
while [ $# -gt 0 ]; do
  case "$1" in
    --project) [ $# -ge 2 ] || { echo "--project needs a directory"; exit 2; }; target="$2/.claude/skills"; shift 2 ;;
    --without-review) skills=(dev-flow dev-plan dev-implement); shift ;;
    --without-security) skills=(dev-flow dev-plan dev-implement dev-review-logic); shift ;;
    --force) force=1; shift ;;
    -h|--help) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1"; exit 2 ;;
  esac
done
mkdir -p "$target"
for s in "${skills[@]}"; do
  if [ -e "$target/$s" ] && [ "$force" -ne 1 ]; then echo "skip    $s (already installed; use --force to overwrite)"; continue; fi
  mkdir -p "$target/$s" && cp "$here/skills/$s/SKILL.md" "$target/$s/SKILL.md" && echo "install $s"
done
echo "Skills are in $target. Start a new Claude Code session and type /dev-flow."
