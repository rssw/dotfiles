#!/bin/sh

# Portable bootstrap for this dotfiles repo.
#
# This script currently favors safe, non-destructive setup over complete
# coverage. It installs packages, initializes submodules, and links only the
# config paths that are already classified as portable enough for reuse.
#
# Common edits:
# - package groups: edit the package variables below
# - portable config coverage: edit `CONFIG_ENTRIES`
# - root-level links: edit the list in `link_root_entries`
# - machine/private setup: keep it out of this script until it is split cleanly

set -eu

DOTFILES_DIR=${DOTFILES_DIR:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}
HOME_DIR=${HOME:?HOME must be set}

DRY_RUN=0
INSTALL_PACKAGES=1
INIT_SUBMODULES=1
LINK_CONFIG=1
MODE=full
CONFLICT_MODE=skip

WITH_NALA=1
WITH_MAIL=1
WITH_LF=1
WITH_TASKWARRIOR=1
WITH_EXTRA_SHELL=1

REQUIRED_PACKAGES="zsh bash git less direnv fzf zsh-autosuggestions zsh-syntax-highlighting neovim tmux ripgrep fd-find jq fastfetch pv p7zip-full unzip cifs-utils exfatprogs nfs-common"
PKG_NALA="nala"
PKG_MAIL="mutt msmtp"
PKG_LF="lf"
PKG_TASKWARRIOR="taskwarrior"
PKG_EXTRA_SHELL="wl-clipboard xclip xsel gpg pinentry-curses"

# Start with a conservative portable subset. Local/private or highly
# desktop-specific config can be linked manually until those layers are split
# more clearly.
CONFIG_ENTRIES="direnv gh git htop lf mpv nix-init nixpkgs nvim octave pip pistol pulse ranger rtv stig tox vifm vimfx"

ROOT_LINK_ENTRIES=".bashrc .bin .config .infokey .inputrc .p10k.zsh .pam_environment .shell .terminfo .tmux .tmux.conf .vim .vimrc .zlogin .zsh .zshenv .zshrc bin"

# Tracked but intentionally excluded from automatic linking for now:
# - beets: local plugin paths and private include
# - gh auth stays local; only portable CLI defaults are linked
# - letsencrypt: domain- and account-specific
# - lyvi, mpDris2, profanity: service- or account-specific
# - beets, newsbeuter, newsboat: retained for later archival or review, not deployment targets
# - .ncmpc, .ncmpcpp, .nyx, .pandoc, .texmf, .tmate.conf, .urxvt, .w3m: legacy or niche root-level configs, not part of the current deployment footprint

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [options]

Default behavior is a full install for Debian/Ubuntu-family systems:
- install required packages and selected optional packages
- initialize git submodules
- link repo-managed config into HOME
- prepare local state directories

The current default full profile includes `nala`, mail tooling (`mutt` and
`msmtp`), `lf`, `taskwarrior`, and extra shell integrations.

Options:
  --full                Enable the default full profile
  --minimal             Install only required packages and core links
  --with-nala           Include nala
  --without-nala        Exclude nala
  --with-mutt           Include mutt
  --without-mutt        Exclude mutt
  --with-lf             Include lf
  --without-lf          Exclude lf
  --with-taskwarrior    Include taskwarrior
  --without-taskwarrior Exclude taskwarrior
  --no-mail             Exclude mail-related optional packages
  --no-extra-shell      Exclude extra shell integrations packages
  --backup-existing     Backup conflicting existing paths before installing
  --no-packages         Skip package installation
  --no-submodules       Skip git submodule initialization
  --no-link             Skip symlink creation
  --dry-run             Print actions without making changes
  --help                Show this help text
EOF
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

run() {
  log "+ $*"
  if [ "$DRY_RUN" -eq 0 ]; then
    "$@"
  fi
}

append_packages() {
  package_list=$1
  shift

  for package_name in "$@"; do
    case " $package_list " in
      *" $package_name "*) ;;
      *) package_list="$package_list $package_name" ;;
    esac
  done

  printf '%s\n' "$package_list"
}

normalize_mode() {
  if [ "$MODE" = "minimal" ]; then
    WITH_NALA=0
    WITH_MAIL=0
    WITH_LF=0
    WITH_TASKWARRIOR=0
    WITH_EXTRA_SHELL=0
  fi
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --full) MODE=full ;;
      --minimal) MODE=minimal ;;
      --with-nala) WITH_NALA=1 ;;
      --without-nala) WITH_NALA=0 ;;
      --with-mutt) WITH_MAIL=1 ;;
      --without-mutt) WITH_MAIL=0 ;;
      --with-lf) WITH_LF=1 ;;
      --without-lf) WITH_LF=0 ;;
      --with-taskwarrior) WITH_TASKWARRIOR=1 ;;
      --without-taskwarrior) WITH_TASKWARRIOR=0 ;;
      --no-mail) WITH_MAIL=0 ;;
      --no-extra-shell) WITH_EXTRA_SHELL=0 ;;
      --backup-existing) CONFLICT_MODE=backup ;;
      --no-packages) INSTALL_PACKAGES=0 ;;
      --no-submodules) INIT_SUBMODULES=0 ;;
      --no-link) LINK_CONFIG=0 ;;
      --dry-run) DRY_RUN=1 ;;
      --help)
        usage
        exit 0
        ;;
      *)
        warn "unknown option: $1"
        usage >&2
        exit 1
        ;;
    esac
    shift
  done

  normalize_mode
}

ensure_supported_platform() {
  if [ "$INSTALL_PACKAGES" -eq 0 ]; then
    return 0
  fi

  if [ ! -f /etc/debian_version ]; then
    warn "package installation currently targets Debian/Ubuntu-family systems only"
    warn "rerun with --no-packages if you only want links and local directories"
    exit 1
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    warn "apt-get is required for package installation"
    exit 1
  fi
}

build_package_list() {
  package_list=$REQUIRED_PACKAGES

  if [ "$WITH_NALA" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_NALA)
  fi
  if [ "$WITH_MAIL" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_MAIL)
  fi
  if [ "$WITH_LF" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_LF)
  fi
  if [ "$WITH_TASKWARRIOR" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_TASKWARRIOR)
  fi
  if [ "$WITH_EXTRA_SHELL" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_EXTRA_SHELL)
  fi

  printf '%s\n' "$package_list"
}

install_packages() {
  if [ "$INSTALL_PACKAGES" -eq 0 ]; then
    log "Skipping package installation"
    return 0
  fi

  package_list=$(build_package_list)
  log "Installing packages:$package_list"
  run sudo apt-get update
  run sudo apt-get install -y $package_list
}

init_submodules() {
  if [ "$INIT_SUBMODULES" -eq 0 ]; then
    log "Skipping submodule initialization"
    return 0
  fi

  run git -C "$DOTFILES_DIR" submodule update --init --recursive
}

ensure_dir() {
  target_dir=$1
  if [ -d "$target_dir" ]; then
    return 0
  fi
  run mkdir -p "$target_dir"
}

install_template_if_missing() {
  template_source_path=$1
  template_target_path=$2

  if [ -e "$template_target_path" ] || [ -L "$template_target_path" ]; then
    if ! handle_conflict "$template_target_path"; then
      return 0
    fi
  fi

  run cp "$template_source_path" "$template_target_path"
}

handle_conflict() {
  conflict_target_path=$1

  case "$CONFLICT_MODE" in
    skip)
      warn "skipping existing path: $conflict_target_path"
      return 1
      ;;
    backup)
      backup_suffix=$(date +%Y%m%d%H%M%S)
      backup_path="${conflict_target_path}.bootstrap-backup.${backup_suffix}"
      warn "backing up existing path: $conflict_target_path -> $backup_path"
      run mv "$conflict_target_path" "$backup_path"
      return 0
      ;;
    *)
      warn "unsupported conflict mode: $CONFLICT_MODE"
      return 1
      ;;
  esac
}

link_one() {
  link_source_path=$1
  link_target_path=$2

  if [ -L "$link_target_path" ]; then
    current_target=$(readlink "$link_target_path" || true)
    if [ "$current_target" = "$link_source_path" ]; then
      log "Already linked: $link_target_path"
      return 0
    fi
  fi

  if [ -e "$link_target_path" ] || [ -L "$link_target_path" ]; then
    if ! handle_conflict "$link_target_path"; then
      return 0
    fi
  fi

  run ln -s "$link_source_path" "$link_target_path"
}

link_root_entries() {
  for name in $ROOT_LINK_ENTRIES
  do
    entry_source_path=$DOTFILES_DIR/$name
    case "$name" in
      .config)
        ensure_dir "$HOME_DIR/.config"
        for config_name in $CONFIG_ENTRIES; do
          config_path=$entry_source_path/$config_name
          [ -e "$config_path" ] || continue
          link_one "$config_path" "$HOME_DIR/.config/$(basename "$config_path")"
        done
        ;;
      bin)
        link_one "$entry_source_path" "$HOME_DIR/bin"
        ;;
      *)
        link_one "$entry_source_path" "$HOME_DIR/$name"
        ;;
    esac
  done
}

prepare_local_state() {
  ensure_dir "$HOME_DIR/.cache"
  ensure_dir "$HOME_DIR/.local/share"
  ensure_dir "$HOME_DIR/.local/share/fzf"
  ensure_dir "$HOME_DIR/.local/share/git"
  ensure_dir "$HOME_DIR/.local/share/mutt"
  ensure_dir "$HOME_DIR/.local/share/mailutils"
  ensure_dir "$HOME_DIR/.local/share/nvim"
  ensure_dir "$HOME_DIR/.local/share/zsh"
  ensure_dir "$HOME_DIR/.local/share/zsh/env"
  ensure_dir "$HOME_DIR/.local/share/zsh/login"

  if [ ! -e "$HOME_DIR/.local/share/zsh/history" ]; then
    run touch "$HOME_DIR/.local/share/zsh/history"
  fi
  if [ ! -e "$HOME_DIR/.local/share/bash-history" ]; then
    run touch "$HOME_DIR/.local/share/bash-history"
  fi
  if [ ! -e "$HOME_DIR/.local/share/less-history" ]; then
    run touch "$HOME_DIR/.local/share/less-history"
  fi

  install_template_if_missing "$DOTFILES_DIR/.config/git/local.example" "$HOME_DIR/.local/share/git/config"
  ensure_dir "$HOME_DIR/.config/msmtp"
  install_template_if_missing "$DOTFILES_DIR/.config/msmtp/config.example" "$HOME_DIR/.config/msmtp/config"
  install_template_if_missing "$DOTFILES_DIR/.archive/.mutt/private.rc.example" "$HOME_DIR/.local/share/mutt/private.rc"
}

link_config() {
  if [ "$LINK_CONFIG" -eq 0 ]; then
    log "Skipping symlink creation"
    return 0
  fi

  link_root_entries
  prepare_local_state
}

main() {
  parse_args "$@"
  ensure_supported_platform

  log "Bootstrap mode: $MODE"
  [ "$DRY_RUN" -eq 0 ] || log "Dry run enabled"

  install_packages
  init_submodules
  link_config

  log "Bootstrap complete"
}

main "$@"
