#!/bin/zsh

# {{{ PATH additions
# {{{ function to append $PATH a directory only if it doesn't exist already.
# On my personal computer at home, this function exists for all users.The
# difference is that the system-wide function appends the argument in the
# beginning of $PATH and not at the end of $PATH - It makes sense because this
# way a user has the choice of using custom scripts with the same name as some
# that exist already on the system. When the interpretor reads $PATH it
# searches through the first directories first. So scripts in ~/.bin will be
# prefered over /bin for example.
add2PATH(){
	# For all strings passed to function
	for i in "$@"; do
		# If the directory exists
		if [ -d "$i" ]; then
			# If it doesn't exists already in $PATH
			if ! echo $PATH | grep -q "$i"; then
				PATH="$i"":""$PATH"
			fi
		fi
	done
}
# }}}

add2PATH "$HOME/.gem/ruby/$(find $HOME/.gem/ruby -maxdepth 1 -mindepth 1 -type d | sort -rn | head -n1)/bin"
add2PATH "$HOME/.local/bin"
add2PATH "$HOME/.bin"
add2PATH "$HOME/bin"

# }}}

# {{{ Programs's settings
# - gcc
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
# - less
export LESS="-X -x4 -r -i"
export LESSHISTFILE="$HOME/.local/share/less-history"
# - ranger: make it not load default rc.conf from /etc so startup will be faster
export RANGER_LOAD_DEFAULT_RC="FALSE"
# - translate-shell
export HOME_LANG="he"
export TARGET_LANG="he"
# - MPD music directory:
export MPD_MUSIC_DIR="$(awk -F'"' '{if ($0 ~ /music_dir/) print $2}' /etc/mpd.conf)"
# - YouTube Channel ID for youtube-viewer (perl application)
export YOUTUBE_CHANNEL_ID="UCRymTwOOJEx-BEqfQRp5T5Q"
# - todo.sh
source "$HOME/.todo/dropbox"
# - ssh
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# }}}

# {{{ PAGER and VISUAL/EDITOR
# {{{ Check If a command is installed locally in /usr/local/bin/ or ~/.local/bin/ and not /usr/bin/ for example.
_command_is_local(){
	if type "$1" | grep -q local; then
		return 0
	else
		return 1
	fi
}
# }}}

# {{{ Show if a command exists
# Taken from http://stackoverflow.com/a/592649/4935114
_command_exists () {
	type "$1" &> /dev/null ;
}
# }}}

if _command_exists nvim; then
	export EDITOR="nvim"
	export VISUAL="nvim"
	if _command_is_local nvim; then
		export VIMRUNTIME="/usr/local/share/nvim/runtime"
	else
		export VIMRUNTIME="/usr/share/nvim/runtime"
	fi
elif _command_exists vim; then
	export EDITOR="vim"
	export VISUAL="vim"
fi
export PAGER="less"
# }}}

# {{{ Genreal settings and variables
# - I always forget this one before I parse commands outputs etc:
IFS=$'\n'
# - xdg browser
export BROWSER="google-chrome-stable"
# - Source xdg settings from .config/user-dirs.dirs
source "$HOME/.config/user-dirs.dirs"
# }}}

# vim:ft=zsh:foldmethod=marker
