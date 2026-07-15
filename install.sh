#!/usr/bin/env bash
#
# Dotfiles bootstrap for GitHub Copilot Chat "memory".
#
# GitHub Codespaces runs this automatically on every new codespace you create
# (once you point Settings -> Codespaces -> "Automatically install dotfiles" at
# this repo). It seeds your Copilot memory files so your preferences follow you
# into every codespace, without committing anything into the target repo.
#
# Safe to re-run by hand at any time:  bash ~/dotfiles/install.sh
#
set -euo pipefail

log() { printf '[copilot-memory] %s\n' "$1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$DOTFILES_DIR/copilot-memory"

# Copilot Chat uses different casing for the two storage roots (verified via the
# memory tool's resolved URIs):
#   globalStorage  -> github.copilot-chat   (lowercase)
#   workspaceStorage-> GitHub.copilot-chat   (mixed case)
GLOBAL_EXT="github.copilot-chat"
WORKSPACE_EXT="GitHub.copilot-chat"
MEMORY_SUBPATH="memory-tool/memories"

# Candidate VS Code "User" data roots, most-likely first. Codespaces uses
# .vscode-remote; the others are fallbacks for server / local installs.
USER_DATA_ROOTS=(
  "$HOME/.vscode-remote/data/User"
  "$HOME/.vscode-server/data/User"
  "$HOME/.config/Code/User"
)

# --- 1) USER-SCOPE preferences -> global storage (applies to ALL codespaces) ---
seed_global() {
  local root dest seeded=0
  for root in "${USER_DATA_ROOTS[@]}"; do
    # Prefer roots that already exist; still create the primary one if none do.
    [ -d "$root" ] || continue
    dest="$root/globalStorage/$GLOBAL_EXT/$MEMORY_SUBPATH"
    mkdir -p "$dest"
    cp "$SRC/preferences.md" "$dest/preferences.md"
    log "seeded user preferences -> $dest/preferences.md"
    seeded=1
  done

  if [ "$seeded" -eq 0 ]; then
    # Brand-new codespace: the data dir may not exist yet. Create the primary path.
    dest="${USER_DATA_ROOTS[0]}/globalStorage/$GLOBAL_EXT/$MEMORY_SUBPATH"
    mkdir -p "$dest"
    cp "$SRC/preferences.md" "$dest/preferences.md"
    log "seeded user preferences (created default path) -> $dest/preferences.md"
  fi
}

# --- 2) REPO-SCOPE notes -> workspaceStorage of the matching repo (best effort) ---
# A Codespace is created for exactly one repo, checked out at /workspaces/<repo>,
# and has effectively one workspaceStorage hash dir. There is no reliable
# hash->repo metadata file to parse, so instead we:
#   1. Confirm this codespace actually IS the target repo (via the checkout path
#      or $GITHUB_REPOSITORY) so we never leak office-bohemia notes into another repo.
#   2. Seed into every existing workspaceStorage hash dir (there is normally one).
# The hash dir does not exist until VS Code opens the folder, so on a brand-new
# codespace this is a no-op and we print a hint to re-run after the workspace opens.
repo_is_present() {
  local repo="$1"
  [ -d "/workspaces/$repo" ] && return 0
  case "${GITHUB_REPOSITORY:-}" in */"$repo") return 0 ;; esac
  return 1
}

seed_repo() {
  local repo="$1"
  local srcdir="$SRC/repo/$repo"
  [ -d "$srcdir" ] || return 0

  if ! repo_is_present "$repo"; then
    log "this codespace is not '$repo' — skipping its repo notes"
    return 0
  fi

  local root wsroot hashdir dest found=0
  for root in "${USER_DATA_ROOTS[@]}"; do
    wsroot="$root/workspaceStorage"
    [ -d "$wsroot" ] || continue
    for hashdir in "$wsroot"/*/; do
      [ -d "$hashdir" ] || continue
      dest="${hashdir%/}/$WORKSPACE_EXT/$MEMORY_SUBPATH/repo"
      mkdir -p "$dest"
      cp "$srcdir"/*.md "$dest"/
      log "seeded '$repo' repo notes -> $dest"
      found=1
    done
  done

  if [ "$found" -eq 0 ]; then
    log "workspaceStorage not created yet for '$repo' — after the workspace opens, re-run: bash $DOTFILES_DIR/install.sh"
  fi
}

seed_global
seed_repo "office-bohemia"

log "done."
