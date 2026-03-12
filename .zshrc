#!/bin/zsh

# Main interactive zsh profile for the portable shell environment.
#
# This file owns interactive behavior only: it loads the ordered runtime parts
# under `/.zsh/rc/`. Environment and PATH policy live in `.zshenv`.
#
# Common edits:
# - prompt tuning: edit `.p10k.zsh` or `/.zsh/p10k/*`
# - completion/history/widgets/bindings: edit the matching file in `/.zsh/rc/`
# - shell aliases/functions: edit `/.shell/core/`, `/.shell/optional/`, or `/.shell/local/`
# - local machine-only login tweaks: use `.zlogin` or local override files

for zshrc_part in ${ZDOTDIR:-$HOME}/.zsh/rc/*; do
	[ -f "$zshrc_part" ] || continue
	source "$zshrc_part"
done
unset zshrc_part

if [ -n "${TRACE_FUNC}" ]; then
	functions -t "$TRACE_FUNC"
fi

# To profile startup:
# zmodload zsh/zprof
# zprof

# vim:ft=zsh:foldmethod=marker
