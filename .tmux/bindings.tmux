# Portable tmux keymap for the standard terminal workflow.
#
# This file is now just an ordered loader for the smaller binding groups under
# `~/.tmux/bindings/`.

source ~/.tmux/bindings/00-prefix.tmux
source ~/.tmux/bindings/10-general.tmux
source ~/.tmux/bindings/20-windows.tmux
source ~/.tmux/bindings/30-panes.tmux
source ~/.tmux/bindings/40-copy.tmux
source ~/.tmux/bindings/50-macros.tmux

# vim:ft=tmux:foldmethod=marker
