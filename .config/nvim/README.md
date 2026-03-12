# Neovim Config

This directory contains the Neovim layer of the portable terminal-first setup.

- `init.vim`
  - main editor entrypoint
  - owns global defaults, runtime setup, backup/view paths, and host overlay loading
- `plugin/`
  - repo-local keymaps and plugin-specific settings split by purpose
  - navigation and split behavior should stay aligned with tmux policy
- `pack/`
  - plugin tree managed mostly through git submodules
- `host-specific/`
  - machine-specific overlays retained from the inherited config
  - standard behavior should gradually move out of here into the portable base
- `plugin/portable-advanced.vim` and `lua/portable_advanced.lua`
  - optional advanced layer for richer UI, completion, treesitter, fuzzy finder,
    and DAP integrations
  - disable it temporarily with `NVIM_PORTABLE_BASE_ONLY=1`

## Design goals

- keep a terminal-first base configuration
- preserve tmux-aware movement with `Ctrl-h/j/k/l`, while retaining native `Ctrl-w h/j/k/l` as the direct Vim-only fallback
- support optional layers without hiding the plain Vim behavior underneath
- keep trust-sensitive features explicit and documented

## Common edits

- change core editor defaults in `.config/nvim/init.vim`
- change custom maps in `.config/nvim/plugin/`
- add or update plugins under `.config/nvim/pack/`
- keep machine-local behavior isolated under `.config/nvim/host-specific/`

## Key defaults

- leader is `Space`
- local leader is `Space`

## Optional plugin model

- `pack/*/start` plugins load automatically at startup
- `pack/*/opt` plugins load only when explicitly requested with `:packadd`
- the advanced layer (`plugin/portable-advanced.vim`) is the main place where optional plugins are enabled by default
- ad-hoc enabling is also available with `ENABLE_PLUGINS=name1,name2 nvim`

## Current workflows

- `fzf-lua`
  - commands: `:Files`, `:Buffers`, `:Lines`, `:RG [pattern]`
  - insert-mode completion helpers: `<C-x><C-f>` paths, `<C-x><C-l>` lines
- `vim-dispatch` and `dispatch-neovim`
  - run `:Dispatch <cmd>` to execute an async build/test command inside Neovim
  - Neovim uses `dispatch-neovim` to back `:Dispatch` with terminal jobs instead of relying on tmux
- file navigation
  - `:E` / `:Explore` for built-in file browsing
  - inside netrw: `Enter` opens, `-` goes up a directory, `q` closes the browser window
  - `<leader>e` opens `lf.vim` on the current file path
  - `:Files` / `:Buffers` for fuzzy navigation with `fzf-lua`
- diff helpers
  - `vdiff left right` from the shell launches `nvim -d` for files or `DirDiff` for directories

## Testing

- restart Neovim or run `:source $MYVIMRC`
- for startup timing checks: `nvim --startuptime nvim.log -c 'q' && sort -k2,2 nvim.log`
