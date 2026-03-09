# Tmux Config

This directory contains the tmux layer of the portable terminal workflow.

- `../.tmux.conf`
  - main tmux entrypoint
  - sets terminal behavior, env propagation, and sources the files below
- `bindings.tmux`
  - custom keymap and cross-application navigation policy
  - keeps `Ctrl-h/j/k/l` aligned with Neovim split movement
  - uses `Alt-h/l` for tmux window movement and `Alt-Arrow` for pane resizing
- `theme.tmux`
  - appearance and status line settings
- `init.tmux`
  - helper startup logic retained from the inherited config

## Design goals

- keep tmux fast and terminal-first
- preserve the inherited `C-s` prefix
- make pane movement consistent with Neovim when Neovim runs inside tmux
- keep native tmux commands available as fallbacks where useful

## Common edits

- change navigation or resize keys in `.tmux/bindings.tmux`
- change colors or status line in `.tmux/theme.tmux`
- change terminal compatibility rules in `../.tmux.conf`

## Testing

- reload tmux with the bound reload key or run `tmux source-file ~/.tmux.conf`
- open Neovim inside tmux and verify `Ctrl-h/j/k/l`, `Alt-h/l`, and `Alt-Arrow`
  still behave as the documented house policy expects
