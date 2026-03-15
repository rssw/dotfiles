# AGENTS.md - Coding Agent Guidelines

**Purpose**: Code style, conventions, and development patterns for AI coding agents working on this repository.

**For users**: See [INSTALL.md](INSTALL.md) for installation instructions and [PORTABLE_PLAN.md](PORTABLE_PLAN.md) for architecture/design decisions.

---

## Project Status

**DONE**:
- bootstrap --verify
- shell modularized (.zsh/rc/*)
- tmux modularized (.tmux/bindings/*)
- Neovim LSP defaults + lsp-install
- managed surface pruned
- Bitwarden/secret-mirror (with Secure Note support)
- mutt base + mbsync hooks
- documentation cleanup and consistency
- LSP installation clarified in docs
- aider/OpenRouter integration via secret-mirror
- dotfiles-help updated with LSP and aider info

**PENDING**:
- LSP flag refinement (add --with-lsp/--without-lsp flags)

---

## Project Overview

This is a **dotfiles repository** containing personal configuration files for various tools (Zsh, Neovim, Tmux, Bash, etc.). It is not a traditional software project.

## Project Structure

```
/home/jacques/src/dotfiles/
├── .zsh/              # Zsh configuration, completions, plugins
├── .zshrc             # Main Zsh configuration
├── .zshenv            # Zsh environment (sourced by all shells)
├── .bashrc            # Bash configuration
├── .config/nvim/      # Neovim configuration (init.vim, plugins)
├── .tmux/             # Tmux configuration
├── .shell/            # Shared shell functions and aliases
└── .bin/              # Personal scripts
```

## Build / Test Commands

**This repository has no build system, tests, or linting.** It's a collection of configuration files.

- Configuration files are loaded by their respective tools (Zsh, Neovim, Tmux, etc.)
- To test changes, restart the relevant tool or source the configuration file
- For Zsh: `source ~/.zshrc` or start a new shell
- For Neovim: `:source $MYVIMRC` or restart Neovim

## Code Style Guidelines

### General Principles

- Configuration files follow the tool's native format and conventions
- Use vim-style fold markers for organization: `{{{1 Section Name`
- Keep files reasonably sized; split into modules when large

### Zsh / Shell Scripts

- Use POSIX-compatible syntax in `.shell/` scripts (prefer `#!/bin/sh`)
- Zsh-specific code goes in `.zshrc`, `.zshenv`, or `.zsh/` directory
- Functions use parentheses syntax: `funcname() { ... }`
- Use `local` for function-local variables
- Prefix private/internal functions with underscore: `_helper_func()`
- Test for command existence before using: `if _command_exists cmd; then ...`

### Neovim

- Primary configuration in Lua (`init.lua`)
- Use `vim.opt.option = value` for options
- Use `vim.g.variable_name = value` for global variables
- Use `vim.api.nvim_create_autocmd()` for autocommands
- Vimscript still used in `plugin/*.vim` for specific functionality
- Prefer native vim features over plugins when possible

### Tmux

- Configuration in `.tmux/` directory, sourced by `init.tmux`
- Use tmux key bindings with `bind` and `unbind`
- Set options with `set -g option value`

### Naming Conventions

- Configuration files: lowercase with leading dot (`.zshrc`, `.vimrc`)
- Functions: lowercase with underscores (`git_clone`, `cd_to_git`)
- Variables: uppercase for environment variables, lowercase for locals

### Error Handling

- Shell scripts: use `set -e` for strict error handling when appropriate
- Neovim: use `if has('feature')` guards for feature detection

## Version Control

- This repository uses Git with submodules for plugin dependencies
- Commit message style: concise, imperative mood ("Add X" not "Added X")
- Keep sensitive files (`.ssh/`, credentials) in `.gitignore`

## Common Tasks

### Adding a new shell alias/function
Edit `.shell/<category>` (e.g., `.shell/git`) or create a new file in `.shell/`

### Adding a new Neovim setting
Edit `.config/nvim/init.lua` in the appropriate section, or add to `plugin/*.vim` for specific keymaps/features

### Adding a new Zsh setting
Edit `.zshrc` in the appropriate section using fold markers

### Testing Neovim configuration
```sh
nvim --startuptime nvim.log -c 'q' && sort -k2,2 nvim.log
```

## Notes

- Some configurations may be system-specific (Linux, WSL, macOS)
- Use environment checks: `if [[ "$OSTYPE" == "linux-gnu"* ]]; then ...`
- Display checks: `if [ -n "$DISPLAY" ]; then ...`
