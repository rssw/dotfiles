#!/bin/sh

# Lightweight verification harness for the deployment repo.
#
# This script does not apply the environment to the current machine. It checks
# syntax, validates tracked config files, and runs bootstrap in dry-run mode
# against throwaway HOME directories so we can verify planned behavior safely.

set -eu

DOTFILES_DIR=${DOTFILES_DIR:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}

log() {
  printf '%s\n' "$*"
}

skip_check() {
  check_name=$1
  shift

  log "==> $check_name"
  log "skipped: $*"
}

run_check() {
  check_name=$1
  shift

  log "==> $check_name"
  "$@"
}

run_check_if_command_exists() {
  check_name=$1
  command_name=$2
  shift 2

  if ! command -v "$command_name" >/dev/null 2>&1; then
    skip_check "$check_name" "$command_name is not installed"
    return 0
  fi

  run_check "$check_name" "$@"
}

make_fake_home() {
  sandbox_root=$1
  fake_home=$sandbox_root/home

  mkdir -p "$fake_home"
  mkdir -p "$fake_home/.config"
  printf '%s\n' "$fake_home"
}

run_bootstrap_dry_run() {
  mode_name=$1
  shift

  sandbox_root=$(mktemp -d)
  trap 'rm -rf "$sandbox_root"' EXIT INT TERM HUP
  fake_home=$(make_fake_home "$sandbox_root")

  log "Using sandbox HOME: $fake_home"
  HOME="$fake_home" DOTFILES_DIR="$DOTFILES_DIR" "$DOTFILES_DIR/bootstrap.sh" --dry-run "$@"

  rm -rf "$sandbox_root"
  trap - EXIT INT TERM HUP
}

run_check "bootstrap shell syntax" sh -n "$DOTFILES_DIR/bootstrap.sh"
run_check "verification shell syntax" sh -n "$DOTFILES_DIR/verify-bootstrap.sh"
run_check_if_command_exists "zsh startup syntax" zsh zsh -n "$DOTFILES_DIR/.zshenv" "$DOTFILES_DIR/.zshrc" "$DOTFILES_DIR/.zlogin"
run_check_if_command_exists "bash startup syntax" bash bash -n "$DOTFILES_DIR/.bashrc"
run_check_if_command_exists "git config syntax" git sh -c "git config -f '$DOTFILES_DIR/.config/git/config' --list >/dev/null && git config -f '$DOTFILES_DIR/.config/git/local.example' --list >/dev/null"
run_check_if_command_exists "Neovim headless load" nvim nvim --headless +q
run_check_if_command_exists "tmux config load" tmux sh -c "tmux -L opencode-verify -f '$DOTFILES_DIR/.tmux.conf' new-session -d -s verify && tmux -L opencode-verify kill-server"
run_check "bootstrap minimal dry-run" run_bootstrap_dry_run minimal --minimal
run_check "bootstrap full dry-run" run_bootstrap_dry_run full --full

log "All verification checks passed"
