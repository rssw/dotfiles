#!/bin/zsh

# Portable shell environment shared by zsh and bash.
#
# This file owns environment variables that should exist before interactive
# shell setup begins: PATH construction, editor/pager defaults, helper
# functions used by both shells, and local host-specific environment includes.
#
# Common edits:
# - PATH precedence or repo location: edit the PATH section below.
# - Editor or pager policy: edit the VISUAL/EDITOR and Pager sections below.
# - Local machine-only environment: add files under
#   `$DOTFILES_DIR/.local/share/zsh/env/$HOST`.
#
# This file should stay shell-portable enough to be sourced from `.bashrc`.

# {{{1 Default IFS
export DEFAULT_IFS="$IFS"

# {{{1 Dotfiles location
if [[ -z "${DOTFILES_DIR:-}" ]]; then
	# Prefer an editable source checkout when present; otherwise assume the files
	# are installed into HOME via symlinks.
	if [[ -d "$HOME/src/dotfiles" ]]; then
		export DOTFILES_DIR="$HOME/src/dotfiles"
	else
		export DOTFILES_DIR="$HOME"
	fi
fi

# {{{1 HOST - from some reason this is not exported by default
export HOST

# {{{1 SSH_ORIGINAL_TERM - used by my ssh configs - part of the environment that's set
export SSH_ORIGINAL_TERM="$TERM"

# {{{1 Misc
# translate-shell
export HOME_LANG=en
export TARGET_LANG=en
# Pistol (https://github.com/doronbehar/pistol)
#export PISTOL_CHROMA_STYLE=monokai
# GCC
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
# Go
#export GOPATH=$HOME/.go

# {{{1 `insert2PATH`: function to insert (in the beginning) of $PATH a directory only if it doesn't exist already.
insert2PATH(){
	# Simple test to mitigate duplications
	if [[ ! $PATH =~ "$1" ]]; then
		PATH="$1"":""$PATH"
	fi
}

insert2PATH "$HOME/bin"
insert2PATH "$HOME/bin/shared"
insert2PATH "$DOTFILES_DIR/.local/bin"
insert2PATH "$DOTFILES_DIR/.bin"
if [[ -d "$DOTFILES_DIR/.nix-profile/bin" ]]; then
	insert2PATH "$DOTFILES_DIR/.nix-profile/bin"
fi
if [[ -d "/usr/local/go/bin" ]]; then
	insert2PATH "/usr/local/go/bin"
fi

# {{{1 `_command_exists`: Show if a command exists
# Taken from http://stackoverflow.com/a/592649/4935114
_command_exists () {
	type "$1" &> /dev/null ;
}

# - {{{1 `source_config_dir`: source all plain files in a directory
source_config_dir() {
	local config_dir config_file

	config_dir="$1"
	[ -d "$config_dir" ] || return 0

	for config_file in "$config_dir"/*; do
		[ -f "$config_file" ] || continue
		case "${config_file##*/}" in
			.*) continue ;;
		esac
		. "$config_file"
	done
}

# - {{{1 VISUAL/EDITOR
if _command_exists nvim; then
	# Older versions of neovim use NVIM_LISTEN_ADDRESS
	if [ -z "${NVIM_LISTEN_ADDRESS+1}" ] && [ -z "${NVIM+1}" ]; then
		export EDITOR="nvim"
		# Default to soft wrapping, `:ManHW` is defined in case hardwrapping is needed
		export MANWIDTH=999
		export MANPAGER="$EDITOR +Man!"
		function manhw() {
			env MANWIDTH=$COLUMNS man "$@"
		}
		export GIT_EDITOR="$EDITOR"
	else
		# Only git needs to know when the editor exits
		export GIT_EDITOR="nvr --remote-silent --remote-wait"
		export EDITOR="nvr"
		export MANPAGER="$EDITOR -c 'set ft=man' -"
	fi
	export SUDO_EDITOR="$EDITOR"
elif _command_exists vim; then
	export EDITOR="vim"
	export MANPAGER="$EDITOR -M +MANPAGER -"
	export GIT_EDITOR="$EDITOR"
	export SUDO_EDITOR="env VIM=${HOME}/.vim $EDITOR"
else
	# taken from wiki.archlinux.org
	export MANPAGER=env\ LESS_TERMCAP_mb=$'\E[01;31m'\ LESS_TERMCAP_md=$'\E[01;38;5;74m'\ LESS_TERMCAP_me=$'\E[0m'\ LESS_TERMCAP_se=$'\E[0m'\ LESS_TERMCAP_so=$'\E[38;5;246m'\ LESS_TERMCAP_ue=$'\E[0m'\ LESS_TERMCAP_us=$'\E[04;38;5;146m'\ less
fi
export VISUAL="$EDITOR"

# - {{{1 Pager and info 
export PAGER="less"
export LESS="-X -x4 -r -i"
export LESSHISTFILE="${HOME}/.local/share/less-history"
export INFO_PRINT_COMMAND="${DOTFILES_DIR}/.bin/info-print"

# - {{{1 FZF
export FZF_DEFAULT_OPTS="--history=$HOME/.local/share/fzf/history"

# - {{{1 local environmental variables
if [[ -f "$DOTFILES_DIR/.local/share/zsh/env/${HOST}" ]]; then
	source "$DOTFILES_DIR/.local/share/zsh/env/${HOST}"
fi

if [[ "$OSTYPE" == "msys" ]]; then
	export XDG_CONFIG_HOME=$HOME/AppData/Local
fi

# - {{{1
# vim:ft=zsh:foldmethod=marker

export MIBS=+ALL
#snmptranslate -m ALL -IR mtxrWlRTabSignalStrength
