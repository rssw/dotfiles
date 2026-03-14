#!/bin/zsh

# Main interactive zsh profile.

for zshrc_part in ${ZDOTDIR:-$HOME}/.zsh/rc/*; do
	[ -f "$zshrc_part" ] || continue
	source "$zshrc_part"
done
unset zshrc_part