#!/bin/bash

# Portable bootstrap for this dotfiles repo.
#
# This script currently favors safe, non-destructive setup over complete
# coverage. It installs packages, initializes submodules, and links only the
# config paths that are already classified as portable enough for reuse.
#
# Common edits:
# - package groups: edit the capability-based package variables below
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
VERIFY_ONLY=0
MODE=full
CONFLICT_MODE=skip

WITH_NALA=1
WITH_MAIL=1
WITH_LF=1
WITH_TASKWARRIOR=1
WITH_EXTRA_SHELL=1
WITH_BITWARDEN=1
WITH_LSP_DEFAULT=1
FASTFETCH_SOURCE_ADDED=0

PKG_CORE_SHELL="zsh bash git less curl"
PKG_CORE_PROMPT="fontconfig fonts-firacode fonts-jetbrains-mono"
PKG_CORE_NAVIGATION="direnv fzf ripgrep fd-find jq pv p7zip-full unzip"
PKG_CORE_EDITOR="zsh-autosuggestions zsh-syntax-highlighting neovim tmux"
PKG_CORE_SYSTEM="cifs-utils exfatprogs nfs-common fastfetch"

PKG_OPTIONAL_NALA="nala"
#!/bin/bash

# Portable bootstrap for this dotfiles repo.
#
# This script currently favors safe, non-destructive setup over complete
# coverage. It installs packages, initializes submodules, and links only the
# config paths that are already classified as portable enough for reuse.
#
# Common edits:
# - package groups: edit the capability-based package variables below
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
VERIFY_ONLY=0
MODE=full
CONFLICT_MODE=skip

WITH_NALA=1
WITH_MAIL=1
WITH_LF=1
WITH_TASKWARRIOR=1
WITH_EXTRA_SHELL=1
WITH_BITWARDEN=1
WITH_LSP_DEFAULT=1
FASTFETCH_SOURCE_ADDED=0

PKG_CORE_SHELL="zsh bash git less curl"
PKG_CORE_PROMPT="fontconfig fonts-firacode fonts-jetbrains-mono"
PKG_CORE_NAVIGATION="direnv fzf ripgrep fd-find jq pv p7zip-full unzip"
PKG_CORE_EDITOR="zsh-autosuggestions zsh-syntax-highlighting neovim tmux"
PKG_CORE_SYSTEM="cifs-utils exfatprogs nfs-common fastfetch"

PKG_OPTIONAL_NALA="nala"
PKG_OPTIONAL_MAIL="mutt msmtp isync notmuch"
PKG_OPTIONAL_FILE_MANAGER="lf"
PKG_OPTIONAL_PRODUCTIVITY="taskwarrior"
PKG_OPTIONAL_EXTRA_SHELL="wl-clipboard xclip xsel gpg pinentry-curses"
PKG_OPTIONAL_LSP_DEFAULT="nodejs npm python3-pip golang-go texlab html-ls cssls typescript-language-server jedi-language-server"


PKG_REQUIRED_GROUPS="PKG_CORE_SHELL PKG_CORE_PROMPT PKG_CORE_NAVIGATION PKG_CORE_EDITOR PKG_CORE_SYSTEM"
FASTFETCH_PPA="ppa:zhangsongcui3371/fastfetch"
MESLO_FONT_BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
MESLO_FONT_FILES="MesloLGS%20NF%20Regular.ttf MesloLGS%20NF%20Bold.ttf MesloLGS%20NF%20Italic.ttf MesloLGS%20NF%20Bold%20Italic.ttf"
BITWARDEN_VERSION="2026.1.0"
BITWARDEN_URL="https://github.com/bitwarden/clients/releases/download/cli-v${BITWARDEN_VERSION}/bw-linux-${BITWARDEN_VERSION}.zip"
BITWARDEN_SERVER_URL="https://rssw.co.za/bitwarden/"

# Start with a conservative portable subset. Local/private or highly
# desktop-specific config can be linked manually until those layers are split
# more clearly.
CONFIG_ENTRIES="direnv gh git htop lf nvim pip"

ROOT_LINK_ENTRIES=".bashrc .bin .config .infokey .inputrc .muttrc .p10k.zsh .pam_environment .shell .terminfo .tmux .tmux.conf .vim .vimrc .zlogin .zsh .zshenv .zshrc bin"

# Tracked but intentionally excluded from automatic linking for now:
# - beets: local plugin paths and private include
# - gh auth stays local; only portable CLI defaults are linked
# - letsencrypt: domain- and account-specific
# - lyvi, mpDris2, profanity: service- or account-specific
# - beets, newsbeuter, newsboat: retained for later archival or review, not deployment targets
# - .ncmpc, .ncmpcpp, .nyx, .pandoc, .texmf, .tmate.conf, .urxvt, .w3m: legacy or niche root-level configs, not part of the current deployment footprint

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

run_in_home() {
  if [ "$DRY_RUN" -eq 0 ]; then
    HOME=$HOME_DIR "$@"
    return 0
  fi

  log "+ HOME=$HOME_DIR $*"
}

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [options]

Default behavior is a full install for Debian/Ubuntu-family systems:
- install required packages and selected optional packages
- initialize git submodules
- link repo-managed config into HOME
- prepare local state directories

Capability groups:
- core shell: zsh, bash, git, less, curl
- prompt/fonts: fontconfig plus bundled prompt fonts and apt font packages
- navigation/search: direnv, fzf, ripgrep, fd, jq, pv, unzip/7zip
- editor/terminal: zsh plugins, Neovim, tmux
- system/storage: cifs, exfat, nfs, fastfetch

The current default full profile also includes `nala`, mail tooling (`mutt` and
`msmtp`), `lf`, `taskwarrior`, Bitwarden CLI, and extra shell integrations.

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
  --with-bitwarden      Include Bitwarden CLI
  --without-bitwarden   Exclude Bitwarden CLI
  --no-mail             Exclude mail-related optional packages
  --no-extra-shell      Exclude extra shell integrations packages
  --backup-existing     Backup conflicting existing paths before installing
  --no-packages         Skip package installation
  --no-submodules       Skip git submodule initialization
  --no-link             Skip symlink creation
  --verify              Check deployed managed paths against the selected profile
  --dry-run             Print actions without making changes
  --help                Show this help text
EOF
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

package_is_selected() {
  package_name=$1
  package_list=$2

  case " $package_list " in
    *" $package_name "*) return 0 ;;
    *) return 1 ;;
  esac
}

package_is_available() {
  package_name=$1

  if [ "$package_name" = "fastfetch" ] && [ "$FASTFETCH_SOURCE_ADDED" -eq 1 ]; then
    return 0
  fi

  apt-cache show "$package_name" >/dev/null 2>&1
}

ensure_fastfetch_repo() {
  package_list=$1

  if ! package_is_selected fastfetch "$package_list"; then
    return 0
  fi

  if package_is_available fastfetch; then
    return 0
  fi

  log "fastfetch is not available in the current apt sources; adding $FASTFETCH_PPA"

  if ! command -v add-apt-repository >/dev/null 2>&1; then
    run sudo apt-get install -y software-properties-common
  fi

  run sudo add-apt-repository -y "$FASTFETCH_PPA"
  run sudo apt-get update
  FASTFETCH_SOURCE_ADDED=1
}

filter_available_packages() {
  package_list=$1
  available_packages=""

  for package_name in $package_list
  do
    if package_is_available "$package_name"; then
      available_packages=$(append_packages "$available_packages" "$package_name")
    else
      warn "package not available in apt sources, skipping: $package_name"
    fi
  done

  printf '%s\n' "$available_packages"
}

normalize_mode() {
  if [ "$MODE" = "minimal" ]; then
    WITH_NALA=0
    WITH_MAIL=0
    WITH_LF=0
    WITH_TASKWARRIOR=0
    WITH_EXTRA_SHELL=0
    WITH_BITWARDEN=0
    WITH_LSP_DEFAULT=0
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
      --with-bitwarden) WITH_BITWARDEN=1 ;;
      --without-bitwarden) WITH_BITWARDEN=0 ;;
      --no-mail) WITH_MAIL=0 ;;
      --no-extra-shell) WITH_EXTRA_SHELL=0 ;;
      --backup-existing) CONFLICT_MODE=backup ;;
      --no-packages) INSTALL_PACKAGES=0 ;;
      --no-submodules) INIT_SUBMODULES=0 ;;
      --no-link) LINK_CONFIG=0 ;;
      --verify) VERIFY_ONLY=1 ;;
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

  if [ "$VERIFY_ONLY" -eq 1 ]; then
    INSTALL_PACKAGES=0
    INIT_SUBMODULES=0
    LINK_CONFIG=0
    DRY_RUN=0
  fi
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
  package_list=""

  for package_group in $PKG_REQUIRED_GROUPS
  do
    eval "group_packages=\${$package_group}"
    package_list=$(append_packages "$package_list" $group_packages)
  done

  if [ "$WITH_NALA" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_NALA)
  fi
  if [ "$WITH_MAIL" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_MAIL)
  fi
  if [ "$WITH_LF" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_FILE_MANAGER)
  fi
  if [ "$WITH_TASKWARRIOR" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_PRODUCTIVITY)
  fi
  if [ "$WITH_EXTRA_SHELL" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_EXTRA_SHELL)
  fi

  printf '%s\n' "$package_list"
}

install_packages() {
  if [ "$INSTALL_PACKAGES" -eq 0 ]; then
    log "Skipping package installation"
    return 0
  fi

  package_list=$(build_package_list)
  run sudo apt-get update
  ensure_fastfetch_repo "$package_list"
  package_list=$(filter_available_packages "$package_list")

  if [ -z "$package_list" ]; then
    warn "no installable packages remain after filtering apt sources"
    return 0
  fi

  log "Installing packages:$package_list"
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

ensure_maildir() {
  maildir_root=$1
  ensure_dir "$maildir_root"
  ensure_dir "$maildir_root/cur"
  ensure_dir "$maildir_root/new"
  ensure_dir "$maildir_root/tmp"
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
        ensure_dir "$HOME_DIR/bin"
        link_one "$entry_source_path" "$HOME_DIR/bin/shared"
        ;;
      *)
        link_one "$entry_source_path" "$HOME_DIR/$name"
        ;;
    esac
  done
}

verify_diff() {
  verify_source_path=$1
  verify_target_path=$2

  if diff -ruN "$verify_source_path" "$verify_target_path" >/dev/null 2>&1; then
    return 0
  fi

  diff -ruN "$verify_source_path" "$verify_target_path" || true
  return 1
}

verify_one() {
  verify_source_path=$1
  verify_target_path=$2

  if [ ! -e "$verify_target_path" ] && [ ! -L "$verify_target_path" ]; then
    printf 'missing: %s (expected %s)\n' "$verify_target_path" "$verify_source_path"
    return 1
  fi

  if [ -L "$verify_target_path" ]; then
    current_target=$(readlink "$verify_target_path" || true)
    if [ "$current_target" = "$verify_source_path" ]; then
      return 0
    fi

    printf 'target mismatch: %s -> %s (expected %s)\n' "$verify_target_path" "$current_target" "$verify_source_path"
    return 1
  fi

  verify_diff "$verify_source_path" "$verify_target_path"
}

verify_root_entries() {
  verify_failed=0

  for name in $ROOT_LINK_ENTRIES
  do
    entry_source_path=$DOTFILES_DIR/$name
    case "$name" in
      .config)
        for config_name in $CONFIG_ENTRIES; do
          config_path=$entry_source_path/$config_name
          [ -e "$config_path" ] || continue
          if ! verify_one "$config_path" "$HOME_DIR/.config/$(basename "$config_path")"; then
            verify_failed=1
          fi
        done
        ;;
      bin)
        if ! verify_one "$entry_source_path" "$HOME_DIR/bin/shared"; then
          verify_failed=1
        fi
        ;;
      *)
        if ! verify_one "$entry_source_path" "$HOME_DIR/$name"; then
          verify_failed=1
        fi
        ;;
    esac
  done

  return "$verify_failed"
}

verify_deployment() {
  if verify_root_entries; then
    return 0
  fi

  return 1
}

prepare_local_state() {
  ensure_dir "$HOME_DIR/.cache"
  ensure_dir "$HOME_DIR/.zkbd"
  ensure_dir "$HOME_DIR/.local/share"
  ensure_dir "$HOME_DIR/.local/share/fzf"
  ensure_dir "$HOME_DIR/.local/share/git"
  ensure_maildir "$HOME_DIR/.local/share/mail/INBOX"
  ensure_maildir "$HOME_DIR/.local/share/mail/Sent"
  ensure_maildir "$HOME_DIR/.local/share/mail/Drafts"
  ensure_maildir "$HOME_DIR/.local/share/mail/Archive"
  ensure_maildir "$HOME_DIR/.local/share/mail/Trash"
  ensure_dir "$HOME_DIR/.local/share/mutt"
  ensure_dir "$HOME_DIR/.local/share/mailutils"
  ensure_dir "$HOME_DIR/.local/share/nvim"
  ensure_dir "$HOME_DIR/.local/share/secret-mirror"
  ensure_dir "$HOME_DIR/.local/share/secrets"
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
  install_template_if_missing "$DOTFILES_DIR/.config/secret-mirror/items.example" "$HOME_DIR/.local/share/secret-mirror/items"
  install_template_if_missing "$DOTFILES_DIR/.archive/.mutt/private.rc.example" "$HOME_DIR/.local/share/mutt/private.rc"
}

install_prompt_fonts() {
  fonts_dir=$HOME_DIR/.local/share/fonts

  ensure_dir "$fonts_dir"

  for font_file in $MESLO_FONT_FILES
  do
    font_name=$(printf '%s' "$font_file" | sed 's/%20/ /g')
    font_target=$fonts_dir/$font_name
    [ -e "$font_target" ] && continue

    font_url=$MESLO_FONT_BASE_URL/$font_file
    if command -v curl >/dev/null 2>&1; then
      run_in_home curl -fsSL -o "$font_target" "$font_url"
    elif command -v wget >/dev/null 2>&1; then
      run_in_home wget -q -O "$font_target" "$font_url"
    else
      warn "cannot install Powerlevel10k font automatically; curl or wget is required"
      return 0
    fi
  done

  if command -v fc-cache >/dev/null 2>&1; then
    run_in_home fc-cache -f "$fonts_dir"
  fi
}

install_bitwarden_cli() {
  [ "$WITH_BITWARDEN" -eq 1 ] || return 0
  [ "$INSTALL_PACKAGES" -eq 1 ] || return 0

  ensure_dir "$HOME_DIR/bin"
  ensure_dir "$HOME_DIR/.local/share/bitwarden"

  bitwarden_target=$HOME_DIR/bin/bw
  if [ -x "$bitwarden_target" ] && "$bitwarden_target" --version 2>/dev/null | grep -q "$BITWARDEN_VERSION"; then
    :
  else
    bitwarden_tmp_dir=$(mktemp -d)
    bitwarden_archive=$bitwarden_tmp_dir/bw.zip

    run_in_home curl -fsSL -o "$bitwarden_archive" "$BITWARDEN_URL"
    run unzip -o "$bitwarden_archive" -d "$bitwarden_tmp_dir"
    run install -m 0755 "$bitwarden_tmp_dir/bw" "$bitwarden_target"
    run rm -rf "$bitwarden_tmp_dir"
  fi

  if [ -n "$BITWARDEN_SERVER_URL" ]; then
    run_in_home "$bitwarden_target" config server "$BITWARDEN_SERVER_URL"
  fi
}

install_lsp_servers() {
  [ "$WITH_LSP_DEFAULT" -eq 1 ] || return 0
  [ "$INSTALL_PACKAGES" -eq 1 ] || return 0

  ensure_dir "$HOME_DIR/bin"
  ensure_dir "$HOME_DIR/.local/share/nvim/lsp"

  # npm-based LSP servers
  if command -v npm >/dev/null 2>&1; then
    run_in_home npm install -g bash-language-server yaml-language-server vscode-html-language-server vscode-css-language-server typescript-language-server
  fi

  # pip-based
  if command -v pip3 >/dev/null 2>&1; then
    run_in_home pip3 install jedi-language-server
  fi

  # go-based
  if command -v go >/dev/null 2>&1; then
    run_in_home go install golang.org/x/tools/gopls@latest
  fi

  # apt-based
  run sudo apt-get install -y texlab
}

ensure_default_shell() {
  [ "$DRY_RUN" -eq 0 ] || return 0
  [ -t 0 ] && [ -t 1 ] || return 0
  command -v zsh >/dev/null 2>&1 || return 0
  command -v getent >/dev/null 2>&1 || return 0

  zsh_path=$(command -v zsh)
  current_shell=$(getent passwd "$USER" | cut -d: -f7 || true)

  if [ "$current_shell" = "$zsh_path" ]; then
    return 0
  fi

  log "Setting default login shell to zsh"
  run sudo chsh -s "$zsh_path" "$USER"
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
  if [ "$VERIFY_ONLY" -eq 1 ]; then
    verify_deployment
    return $?
  fi

  ensure_supported_platform

  log "Bootstrap mode: $MODE"
  [ "$DRY_RUN" -eq 0 ] || log "Dry run enabled"

  install_packages
  init_submodules
  link_config
  install_bitwarden_cli
  install_lsp_servers
  install_prompt_fonts
  ensure_default_shell

  log "Bootstrap complete"

  if [ "$DRY_RUN" -eq 0 ] && [ -t 0 ] && [ -t 1 ] && command -v zsh >/dev/null 2>&1; then
    if [ "${SHELL##*/}" != "zsh" ]; then
      log "Starting zsh for this session"
      exec zsh -l
    fi
  fi
}

main "$@"

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
  package_list=""

  for package_group in $PKG_REQUIRED_GROUPS
  do
    eval "group_packages=\${$package_group}"
    package_list=$(append_packages "$package_list" $group_packages)
  done

  if [ "$WITH_NALA" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_NALA)
  fi
  if [ "$WITH_MAIL" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_MAIL)
  fi
  if [ "$WITH_LF" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_FILE_MANAGER)
  fi
  if [ "$WITH_TASKWARRIOR" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_PRODUCTIVITY)
  fi
  if [ "$WITH_EXTRA_SHELL" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_EXTRA_SHELL)
  fi

  printf '%s\n' "$package_list"
}

install_packages() {
  if [ "$INSTALL_PACKAGES" -eq 0 ]; then
    log "Skipping package installation"
    return 0
  fi

  package_list=$(build_package_list)
  run sudo apt-get update
  ensure_fastfetch_repo "$package_list"
  package_list=$(filter_available_packages "$package_list")

  if [ -z "$package_list" ]; then
    warn "no installable packages remain after filtering apt sources"
    return 0
  fi

  log "Installing packages:$package_list"
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

ensure_maildir() {
  maildir_root=$1
  ensure_dir "$maildir_root"
  ensure_dir "$maildir_root/cur"
  ensure_dir "$maildir_root/new"
  ensure_dir "$maildir_root/tmp"
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
        ensure_dir "$HOME_DIR/bin"
        link_one "$entry_source_path" "$HOME_DIR/bin/shared"
        ;;
      *)
        link_one "$entry_source_path" "$HOME_DIR/$name"
        ;;
    esac
  done
}

verify_diff() {
  verify_source_path=$1
  verify_target_path=$2

  if diff -ruN "$verify_source_path" "$verify_target_path" >/dev/null 2>&1; then
    return 0
  fi

  diff -ruN "$verify_source_path" "$verify_target_path" || true
  return 1
}

verify_one() {
  verify_source_path=$1
  verify_target_path=$2

  if [ ! -e "$verify_target_path" ] && [ ! -L "$verify_target_path" ]; then
    printf 'missing: %s (expected %s)\n' "$verify_target_path" "$verify_source_path"
    return 1
  fi

  if [ -L "$verify_target_path" ]; then
    current_target=$(readlink "$verify_target_path" || true)
    if [ "$current_target" = "$verify_source_path" ]; then
      return 0
    fi

    printf 'target mismatch: %s -> %s (expected %s)\n' "$verify_target_path" "$current_target" "$verify_source_path"
    return 1
  fi

  verify_diff "$verify_source_path" "$verify_target_path"
}

verify_root_entries() {
  verify_failed=0

  for name in $ROOT_LINK_ENTRIES
  do
    entry_source_path=$DOTFILES_DIR/$name
    case "$name" in
      .config)
        for config_name in $CONFIG_ENTRIES; do
          config_path=$entry_source_path/$config_name
          [ -e "$config_path" ] || continue
          if ! verify_one "$config_path" "$HOME_DIR/.config/$(basename "$config_path")"; then
            verify_failed=1
          fi
        done
        ;;
      bin)
        if ! verify_one "$entry_source_path" "$HOME_DIR/bin/shared"; then
          verify_failed=1
        fi
        ;;
      *)
        if ! verify_one "$entry_source_path" "$HOME_DIR/$name"; then
          verify_failed=1
        fi
        ;;
    esac
  done

  return "$verify_failed"
}

verify_deployment() {
  if verify_root_entries; then
    return 0
  fi

  return 1
}

prepare_local_state() {
  ensure_dir "$HOME_DIR/.cache"
  ensure_dir "$HOME_DIR/.zkbd"
  ensure_dir "$HOME_DIR/.local/share"
  ensure_dir "$HOME_DIR/.local/share/fzf"
  ensure_dir "$HOME_DIR/.local/share/git"
  ensure_maildir "$HOME_DIR/.local/share/mail/INBOX"
  ensure_maildir "$HOME_DIR/.local/share/mail/Sent"
  ensure_maildir "$HOME_DIR/.local/share/mail/Drafts"
  ensure_maildir "$HOME_DIR/.local/share/mail/Archive"
  ensure_maildir "$HOME_DIR/.local/share/mail/Trash"
  ensure_dir "$HOME_DIR/.local/share/mutt"
  ensure_dir "$HOME_DIR/.local/share/mailutils"
  ensure_dir "$HOME_DIR/.local/share/nvim"
  ensure_dir "$HOME_DIR/.local/share/secret-mirror"
  ensure_dir "$HOME_DIR/.local/share/secrets"
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
  install_template_if_missing "$DOTFILES_DIR/.config/secret-mirror/items.example" "$HOME_DIR/.local/share/secret-mirror/items"
  install_template_if_missing "$DOTFILES_DIR/.archive/.mutt/private.rc.example" "$HOME_DIR/.local/share/mutt/private.rc"
}

install_prompt_fonts() {
  fonts_dir=$HOME_DIR/.local/share/fonts

  ensure_dir "$fonts_dir"

  for font_file in $MESLO_FONT_FILES
  do
    font_name=$(printf '%s' "$font_file" | sed 's/%20/ /g')
    font_target=$fonts_dir/$font_name
    [ -e "$font_target" ] && continue

    font_url=$MESLO_FONT_BASE_URL/$font_file
    if command -v curl >/dev/null 2>&1; then
      run_in_home curl -fsSL -o "$font_target" "$font_url"
    elif command -v wget >/dev/null 2>&1; then
      run_in_home wget -q -O "$font_target" "$font_url"
    else
      warn "cannot install Powerlevel10k font automatically; curl or wget is required"
      return 0
    fi
  done

  if command -v fc-cache >/dev/null 2>&1; then
    run_in_home fc-cache -f "$fonts_dir"
  fi
}

install_bitwarden_cli() {
  [ "$WITH_BITWARDEN" -eq 1 ] || return 0
  [ "$INSTALL_PACKAGES" -eq 1 ] || return 0

  ensure_dir "$HOME_DIR/bin"
  ensure_dir "$HOME_DIR/.local/share/bitwarden"

  bitwarden_target=$HOME_DIR/bin/bw
  if [ -x "$bitwarden_target" ] && "$bitwarden_target" --version 2>/dev/null | grep -q "$BITWARDEN_VERSION"; then
    :
  else
    bitwarden_tmp_dir=$(mktemp -d)
    bitwarden_archive=$bitwarden_tmp_dir/bw.zip

    run_in_home curl -fsSL -o "$bitwarden_archive" "$BITWARDEN_URL"
    run unzip -o "$bitwarden_archive" -d "$bitwarden_tmp_dir"
    run install -m 0755 "$bitwarden_tmp_dir/bw" "$bitwarden_target"
    run rm -rf "$bitwarden_tmp_dir"
  fi

  if [ -n "$BITWARDEN_SERVER_URL" ]; then
    run_in_home "$bitwarden_target" config server "$BITWARDEN_SERVER_URL"
  fi
}

install_lsp_servers() {
  [ "$WITH_LSP_DEFAULT" -eq 1 ] || return 0
  [ "$INSTALL_PACKAGES" -eq 1 ] || return 0

  ensure_dir "$HOME_DIR/bin"
  ensure_dir "$HOME_DIR/.local/share/nvim/lsp"

  # npm-based LSP servers
  if command -v npm >/dev/null 2>&1; then
    run_in_home npm install -g bash-language-server yaml-language-server vscode-html-language-server vscode-css-language-server typescript-language-server
  fi

  # pip-based
  if command -v pip3 >/dev/null 2>&1; then
    run_in_home pip3 install jedi-language-server
  fi

  # go-based
  if command -v go >/dev/null 2>&1; then
    run_in_home go install golang.org/x/tools/gopls@latest
  fi

  # apt-based
  run sudo apt-get install -y texlab
}

ensure_default_shell() {
  [ "$DRY_RUN" -eq 0 ] || return 0
  [ -t 0 ] && [ -t 1 ] || return 0
  command -v zsh >/dev/null 2>&1 || return 0
  command -v getent >/dev/null 2>&1 || return 0

  zsh_path=$(command -v zsh)
  current_shell=$(getent passwd "$USER" | cut -d: -f7 || true)

  if [ "$current_shell" = "$zsh_path" ]; then
    return 0
  fi

  log "Setting default login shell to zsh"
  run sudo chsh -s "$zsh_path" "$USER"
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
  if [ "$VERIFY_ONLY" -eq 1 ]; then
    verify_deployment
    return $?
  fi

  ensure_supported_platform

  log "Bootstrap mode: $MODE"
  [ "$DRY_RUN" -eq 0 ] || log "Dry run enabled"

  install_packages
  init_submodules
  link_config
  install_bitwarden_cli
  install_lsp_servers
  install_prompt_fonts
  ensure_default_shell

  log "Bootstrap complete"

  if [ "$DRY_RUN" -eq 0 ] && [ -t 0 ] && [ -t 1 ] && command -v zsh >/dev/null 2>&1; then
    if [ "${SHELL##*/}" != "zsh" ]; then
      log "Starting zsh for this session"
      exec zsh -l
    fi
  fi
}

main "$@"

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

run_in_home() {
  if [ "$DRY_RUN" -eq 0 ]; then
    HOME=$HOME_DIR "$@"
    return 0
  fi

  log "+ HOME=$HOME_DIR $*"
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

package_is_selected() {
  package_name=$1
  package_list=$2

  case " $package_list " in
    *" $package_name "*) return 0 ;;
    *) return 1 ;;
  esac
}

package_is_available() {
  package_name=$1

  if [ "$package_name" = "fastfetch" ] && [ "$FASTFETCH_SOURCE_ADDED" -eq 1 ]; then
    return 0
  fi

  apt-cache show "$package_name" >/dev/null 2>&1
}

ensure_fastfetch_repo() {
  package_list=$1

  if ! package_is_selected fastfetch "$package_list"; then
    return 0
  fi

  if package_is_available fastfetch; then
    return 0
  fi

  log "fastfetch is not available in the current apt sources; adding $FASTFETCH_PPA"

  if ! command -v add-apt-repository >/dev/null 2>&1; then
    run sudo apt-get install -y software-properties-common
  fi

  run sudo add-apt-repository -y "$FASTFETCH_PPA"
  run sudo apt-get update
  FASTFETCH_SOURCE_ADDED=1
}

filter_available_packages() {
  package_list=$1
  available_packages=""

  for package_name in $package_list
  do
    if package_is_available "$package_name"; then
      available_packages=$(append_packages "$available_packages" "$package_name")
    else
      warn "package not available in apt sources, skipping: $package_name"
    fi
  done

  printf '%s\n' "$available_packages"
}

normalize_mode() {
  if [ "$MODE" = "minimal" ]; then
    WITH_NALA=0
    WITH_MAIL=0
    WITH_LF=0
    WITH_TASKWARRIOR=0
    WITH_EXTRA_SHELL=0
    WITH_BITWARDEN=0
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
      --with-bitwarden) WITH_BITWARDEN=1 ;;
      --without-bitwarden) WITH_BITWARDEN=0 ;;
      --no-mail) WITH_MAIL=0 ;;
      --no-extra-shell) WITH_EXTRA_SHELL=0 ;;
      --backup-existing) CONFLICT_MODE=backup ;;
      --no-packages) INSTALL_PACKAGES=0 ;;
      --no-submodules) INIT_SUBMODULES=0 ;;
      --no-link) LINK_CONFIG=0 ;;
      --verify) VERIFY_ONLY=1 ;;
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

  if [ "$VERIFY_ONLY" -eq 1 ]; then
    INSTALL_PACKAGES=0
    INIT_SUBMODULES=0
    LINK_CONFIG=0
    DRY_RUN=0
  fi
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
  package_list=""

  for package_group in $PKG_REQUIRED_GROUPS
  do
    eval "group_packages=\${$package_group}"
    package_list=$(append_packages "$package_list" $group_packages)
  done

  if [ "$WITH_NALA" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_NALA)
  fi
  if [ "$WITH_MAIL" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_MAIL)
  fi
  if [ "$WITH_LF" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_FILE_MANAGER)
  fi
  if [ "$WITH_TASKWARRIOR" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_PRODUCTIVITY)
  fi
  if [ "$WITH_EXTRA_SHELL" -eq 1 ]; then
    package_list=$(append_packages "$package_list" $PKG_OPTIONAL_EXTRA_SHELL)
  fi

  printf '%s\n' "$package_list"
}

install_packages() {
  if [ "$INSTALL_PACKAGES" -eq 0 ]; then
    log "Skipping package installation"
    return 0
  fi

  package_list=$(build_package_list)
  run sudo apt-get update
  ensure_fastfetch_repo "$package_list"
  package_list=$(filter_available_packages "$package_list")

  if [ -z "$package_list" ]; then
    warn "no installable packages remain after filtering apt sources"
    return 0
  fi

  log "Installing packages:$package_list"
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

ensure_maildir() {
  maildir_root=$1
  ensure_dir "$maildir_root"
  ensure_dir "$maildir_root/cur"
  ensure_dir "$maildir_root/new"
  ensure_dir "$maildir_root/tmp"
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
        ensure_dir "$HOME_DIR/bin"
        link_one "$entry_source_path" "$HOME_DIR/bin/shared"
        ;;
      *)
        link_one "$entry_source_path" "$HOME_DIR/$name"
        ;;
    esac
  done
}

verify_diff() {
  verify_source_path=$1
  verify_target_path=$2

  if diff -ruN "$verify_source_path" "$verify_target_path" >/dev/null 2>&1; then
    return 0
  fi

  diff -ruN "$verify_source_path" "$verify_target_path" || true
  return 1
}

verify_one() {
  verify_source_path=$1
  verify_target_path=$2

  if [ ! -e "$verify_target_path" ] && [ ! -L "$verify_target_path" ]; then
    printf 'missing: %s (expected %s)\n' "$verify_target_path" "$verify_source_path"
    return 1
  fi

  if [ -L "$verify_target_path" ]; then
    current_target=$(readlink "$verify_target_path" || true)
    if [ "$current_target" = "$verify_source_path" ]; then
      return 0
    fi

    printf 'target mismatch: %s -> %s (expected %s)\n' "$verify_target_path" "$current_target" "$verify_source_path"
    return 1
  fi

  verify_diff "$verify_source_path" "$verify_target_path"
}

verify_root_entries() {
  verify_failed=0

  for name in $ROOT_LINK_ENTRIES
  do
    entry_source_path=$DOTFILES_DIR/$name
    case "$name" in
      .config)
        for config_name in $CONFIG_ENTRIES; do
          config_path=$entry_source_path/$config_name
          [ -e "$config_path" ] || continue
          if ! verify_one "$config_path" "$HOME_DIR/.config/$(basename "$config_path")"; then
            verify_failed=1
          fi
        done
        ;;
      bin)
        if ! verify_one "$entry_source_path" "$HOME_DIR/bin/shared"; then
          verify_failed=1
        fi
        ;;
      *)
        if ! verify_one "$entry_source_path" "$HOME_DIR/$name"; then
          verify_failed=1
        fi
        ;;
    esac
  done

  return "$verify_failed"
}

verify_deployment() {
  if verify_root_entries; then
    return 0
  fi

  return 1
}

prepare_local_state() {
  ensure_dir "$HOME_DIR/.cache"
  ensure_dir "$HOME_DIR/.zkbd"
  ensure_dir "$HOME_DIR/.local/share"
  ensure_dir "$HOME_DIR/.local/share/fzf"
  ensure_dir "$HOME_DIR/.local/share/git"
  ensure_maildir "$HOME_DIR/.local/share/mail/INBOX"
  ensure_maildir "$HOME_DIR/.local/share/mail/Sent"
  ensure_maildir "$HOME_DIR/.local/share/mail/Drafts"
  ensure_maildir "$HOME_DIR/.local/share/mail/Archive"
  ensure_maildir "$HOME_DIR/.local/share/mail/Trash"
  ensure_dir "$HOME_DIR/.local/share/mutt"
  ensure_dir "$HOME_DIR/.local/share/mailutils"
  ensure_dir "$HOME_DIR/.local/share/nvim"
  ensure_dir "$HOME_DIR/.local/share/secret-mirror"
  ensure_dir "$HOME_DIR/.local/share/secrets"
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
  install_template_if_missing "$DOTFILES_DIR/.config/secret-mirror/items.example" "$HOME_DIR/.local/share/secret-mirror/items"
  install_template_if_missing "$DOTFILES_DIR/.archive/.mutt/private.rc.example" "$HOME_DIR/.local/share/mutt/private.rc"
}

install_prompt_fonts() {
  fonts_dir=$HOME_DIR/.local/share/fonts

  ensure_dir "$fonts_dir"

  for font_file in $MESLO_FONT_FILES
  do
    font_name=$(printf '%s' "$font_file" | sed 's/%20/ /g')
    font_target=$fonts_dir/$font_name
    [ -e "$font_target" ] && continue

    font_url=$MESLO_FONT_BASE_URL/$font_file
    if command -v curl >/dev/null 2>&1; then
      run_in_home curl -fsSL -o "$font_target" "$font_url"
    elif command -v wget >/dev/null 2>&1; then
      run_in_home wget -q -O "$font_target" "$font_url"
    else
      warn "cannot install Powerlevel10k font automatically; curl or wget is required"
      return 0
    fi
  done

  if command -v fc-cache >/dev/null 2>&1; then
    run_in_home fc-cache -f "$fonts_dir"
  fi
}

install_bitwarden_cli() {
  [ "$WITH_BITWARDEN" -eq 1 ] || return 0
  [ "$INSTALL_PACKAGES" -eq 1 ] || return 0

  ensure_dir "$HOME_DIR/bin"
  ensure_dir "$HOME_DIR/.local/share/bitwarden"

  bitwarden_target=$HOME_DIR/bin/bw
  if [ -x "$bitwarden_target" ] && "$bitwarden_target" --version 2>/dev/null | grep -q "$BITWARDEN_VERSION"; then
    :
  else
    bitwarden_tmp_dir=$(mktemp -d)
    bitwarden_archive=$bitwarden_tmp_dir/bw.zip

    run_in_home curl -fsSL -o "$bitwarden_archive" "$BITWARDEN_URL"
    run unzip -o "$bitwarden_archive" -d "$bitwarden_tmp_dir"
    run install -m 0755 "$bitwarden_tmp_dir/bw" "$bitwarden_target"
    run rm -rf "$bitwarden_tmp_dir"
  fi

  if [ -n "$BITWARDEN_SERVER_URL" ]; then
    run_in_home "$bitwarden_target" config server "$BITWARDEN_SERVER_URL"
  fi
}

install_lsp_servers() {
  [ "$WITH_LSP_DEFAULT" -eq 1 ] || return 0
  [ "$INSTALL_PACKAGES" -eq 1 ] || return 0

  ensure_dir "$HOME_DIR/bin"
  ensure_dir "$HOME_DIR/.local/share/nvim/lsp"

  # npm-based LSP servers
  if command -v npm >/dev/null 2>&1; then
    run_in_home npm install -g bash-language-server yaml-language-server vscode-html-language-server vscode-css-language-server typescript-language-server
  fi

  # pip-based
  if command -v pip3 >/dev/null 2>&1; then
    run_in_home pip3 install jedi-language-server
  fi

  # go-based
  if command -v go >/dev/null 2>&1; then
    run_in_home go install golang.org/x/tools/gopls@latest
  fi

  # apt-based
  run sudo apt-get install -y texlab
}

ensure_default_shell() {
  [ "$DRY_RUN" -eq 0 ] || return 0
  [ -t 0 ] && [ -t 1 ] || return 0
  command -v zsh >/dev/null 2>&1 || return 0
  command -v getent >/dev/null 2>&1 || return 0

  zsh_path=$(command -v zsh)
  current_shell=$(getent passwd "$USER" | cut -d: -f7 || true)

  if [ "$current_shell" = "$zsh_path" ]; then
    return 0
  fi

  log "Setting default login shell to zsh"
  run sudo chsh -s "$zsh_path" "$USER"
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
  if [ "$VERIFY_ONLY" -eq 1 ]; then
    verify_deployment
    return $?
  fi

  ensure_supported_platform

  log "Bootstrap mode: $MODE"
  [ "$DRY_RUN" -eq 0 ] || log "Dry run enabled"

  install_packages
  init_submodules
  link_config
  install_bitwarden_cli
  install_lsp_servers
  install_prompt_fonts
  ensure_default_shell

  log "Bootstrap complete"

  if [ "$DRY_RUN" -eq 0 ] && [ -t 0 ] && [ -t 1 ] && command -v zsh >/dev/null 2>&1; then
    if [ "${SHELL##*/}" != "zsh" ]; then
      log "Starting zsh for this session"
      exec zsh -l
    fi
  fi
}

main "$@"
