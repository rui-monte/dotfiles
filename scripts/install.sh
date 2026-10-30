#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/rui-monte/dotfiles.git"
TARGET_DIR="$HOME/dotfiles"

log() {
  printf '==> %s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "$1 is required but is not available on PATH."
  fi
}

target_dir_is_empty() {
  local entries=()

  shopt -s dotglob nullglob
  entries=("$TARGET_DIR"/*)
  shopt -u dotglob nullglob

  [[ ${#entries[@]} -eq 0 ]]
}

main() {
  require_command git

  cd "$HOME"

  if [[ -e "$TARGET_DIR" ]]; then
    if [[ ! -d "$TARGET_DIR" ]]; then
      fail "$TARGET_DIR exists but is not a directory."
    fi

    if ! target_dir_is_empty; then
      fail "$TARGET_DIR already exists and is not empty. Move it aside or remove it before running the installer."
    fi
  fi

  log "Cloning dotfiles into $TARGET_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"

  log "Running bootstrap"
  "$TARGET_DIR/scripts/bootstrap.sh"
}

main "$@"
