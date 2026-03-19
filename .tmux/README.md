# Tmux Config

This directory contains the tmux layer of the portable terminal workflow.

- `../.tmux.conf`
  - main tmux entrypoint
  - sets terminal behavior, env propagation, and sources the files below
- `bindings.tmux`
  - ordered loader for the smaller binding groups under `/.tmux/bindings/`
- `bindings/00-prefix.tmux`
  - prefix and modal defaults
- `bindings/20-windows.tmux`
  - window navigation and the custom split/new-window keys
- `bindings/30-panes.tmux`
  - pane navigation, pane resizing, and tmux/Neovim crossover behavior
- `bindings/40-copy.tmux`
  - copy-mode bindings and clipboard integration
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
- change prefix/default-preserving behavior in `.tmux/bindings/00-prefix.tmux`
- change window or pane behavior in the matching file under `.tmux/bindings/`
- change colors or status line in `.tmux/theme.tmux`
- change terminal compatibility rules in `../.tmux.conf`

## Testing

- reload tmux with the bound reload key or run `tmux source-file ~/.tmux.conf`
- open Neovim inside tmux and verify `Ctrl-h/j/k/l` still crosses cleanly between
  Neovim splits and tmux panes
- verify tmux house bindings still match policy:
  - `Alt-h/j/k/l` resize panes
  - `Alt-Left/Right` switch windows
  - `Ctrl-h/j/k/l` move between panes (and through Neovim when applicable)
