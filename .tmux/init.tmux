# Main tmux entrypoint for the portable terminal workflow.
#
# This file keeps global tmux behavior small and delegates most customization to
# `~/.tmux/theme.tmux` and `~/.tmux/bindings.tmux`.
#
# Common edits:
# - theme/colors: edit `~/.tmux/theme.tmux`
# - keybindings and navigation policy: edit `~/.tmux/bindings.tmux`
# - terminal capability quirks: edit the guards below in this file

# make the escape-time in vim within tmux lower
set-option -sg escape-time 0
if-shell '[[ $TERM =~ "xterm" ]]' 'set-option -g xterm-keys on'
set-option -g history-limit 5000
if-shell '[[ $TERM =~ "-256color" ]]' 'set -g default-terminal tmux-256color'
if-shell '[[ $TERM =~ "-16color" ]]' 'set -g default-terminal screen-16color'
if-shell '[[ $TERM =~ "alacritty" ]]' 'set -g default-terminal tmux-256color'
# Taken from https://github.com/neovim/neovim/wiki/FAQ#cursor-shape-doesnt-change-in-tmux
if-shell '[[ $TERM =~ "rxvt" ]]' 'set -g -a terminal-overrides '"'"',*:Ss=\E[%p1%d q:Se=\E[2 q'"'"
# As explaind here: https://unix.stackexchange.com/a/383044/135796
set -g focus-events on

# Enable mouse support for scrolling within tmux
set -g mouse on

# Make mouse wheel scroll enter copy mode and scroll the tmux buffer
bind-key -T root WheelUpPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
bind-key -T root WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"

# PageUp/PageDown for half-page scrolling in copy mode
bind-key -T copy-mode-vi PageUp send-keys -X halfpage-up
bind-key -T copy-mode-vi PageDown send-keys -X halfpage-down
bind-key -T copy-mode PageUp send-keys -X halfpage-up
bind-key -T copy-mode PageDown send-keys -X halfpage-down

# PageUp enters copy mode from normal mode, but PageDown does nothing
# to avoid accidentally switching modes when already at bottom
bind-key -T root PageUp copy-mode -e \; send-keys -X halfpage-up

set-option -g update-environment "DIRENV_DIFF DIRENV_DIR DIRENV_WATCHES"
set-environment -gu DIRENV_DIFF
set-environment -gu DIRENV_DIR
set-environment -gu DIRENV_WATCHES
set-environment -gu DIRENV_LAYOUT

# Theme:
source ~/.tmux/theme.tmux
# Key bindings:
source ~/.tmux/bindings.tmux

# vim:ft=tmux
