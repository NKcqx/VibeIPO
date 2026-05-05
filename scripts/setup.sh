#!/usr/bin/env bash
# setup.sh — install hk-ipo-analysis as a Cursor skill via symlink
# Usage: scripts/setup.sh [--cursor-skills-dir <path>]

set -euo pipefail

SKILL_NAME="hk-ipo-analysis"
DEFAULT_DIR="$HOME/.cursor/skills"
TARGET_DIR="$DEFAULT_DIR"

while [ $# -gt 0 ]; do
  case "$1" in
    --cursor-skills-dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--cursor-skills-dir <path>]"
      echo ""
      echo "Default skills dir: $DEFAULT_DIR"
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 1
      ;;
  esac
done

# Resolve repo root (parent of scripts/)
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

echo "Repo root:       $REPO_ROOT"
echo "Skills dir:      $TARGET_DIR"
echo "Symlink target:  $TARGET_DIR/$SKILL_NAME"
echo ""

# Create skills dir if missing
mkdir -p "$TARGET_DIR"

LINK_PATH="$TARGET_DIR/$SKILL_NAME"

if [ -L "$LINK_PATH" ]; then
  EXISTING=$(readlink "$LINK_PATH")
  if [ "$EXISTING" = "$REPO_ROOT" ]; then
    echo "✓ Symlink already correct: $LINK_PATH -> $REPO_ROOT"
    exit 0
  else
    echo "⚠ Symlink exists but points to: $EXISTING"
    read -r -p "Overwrite? [y/N] " ans
    [ "$ans" = "y" ] || { echo "Aborted."; exit 1; }
    rm "$LINK_PATH"
  fi
elif [ -e "$LINK_PATH" ]; then
  echo "✗ Path exists and is not a symlink: $LINK_PATH" >&2
  echo "  Move or remove it manually, then re-run." >&2
  exit 1
fi

ln -s "$REPO_ROOT" "$LINK_PATH"
echo "✓ Created: $LINK_PATH -> $REPO_ROOT"
echo ""
echo "Make scripts executable..."
chmod +x "$REPO_ROOT/scripts/"*.sh
echo "✓ Done."
echo ""
echo "Test the skill in Cursor by saying e.g.:"
echo "  「分析下 01609 天星医疗 要不要认购」"
echo ""
echo "Or run scripts directly:"
echo "  $REPO_ROOT/scripts/fetch_ipo_terms.sh 01609"
echo "  $REPO_ROOT/scripts/find_prospectus.sh 01609 zh"
