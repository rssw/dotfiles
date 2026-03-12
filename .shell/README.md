# Shell Module Layout

This directory now separates portable shell behavior into three layers.

- `core/`
  - standard helpers intended for most machines
  - safe defaults such as colors, editor helpers, filesystem helpers, package normalization, and shared command aliases
  - loaded by both `/.zshrc` and `/.bashrc`
- `optional/`
  - integrations that only activate when their backing tools exist
  - examples: desktop helpers, `gpg`, `lf`, `guix`, `mpd`, `tmux`, `wego`
  - also loaded by both `/.zshrc` and `/.bashrc`
- `local/`
  - machine-specific or private shell snippets
  - sourced last so local overrides can adjust standard behavior
  - intended for secrets, host-specific aliases, and personal workflow glue that should not be shared broadly

## Load order

The shell startup order is:

1. `/.zshenv` for shared environment and helper functions
2. ordered `/.zsh/rc/` parts for prompt, completion, history, widgets, and bindings
3. `/.shell/core/`
4. `/.shell/optional/`
5. `/.shell/local/`
6. shell-specific hooks from `/.zshrc`, `/.bashrc`, and `/.zlogin`

## Module guidelines

- keep files plain shell scripts with lowercase names
- guard tool-specific behavior with `_command_exists`
- prefer one topic per file so future help output can group commands cleanly
- put portable defaults in `core/` before adding them to `optional/`
- keep private tokens, machine names, and risky automation out of tracked portable modules

## Common edits

- add general aliases/functions: create or edit a file in `/.shell/core/`
- add package-aware integrations: place them in `/.shell/optional/`
- add host-only overrides: create an untracked file in `/.shell/local/`
- `bin/tm` now supports numbered session selection and uses `fzf` as the interactive picker when available
- zsh interactive behavior is split into ordered parts under `/.zsh/rc/`

Current shared examples:

- `/.shell/core/archive`: `extract`
- `/.shell/core/filesystem`: `md`
- `/.shell/core/fzf`: `fh`
- `/.shell/optional/tmux`: `ta`, `tat`, `tls`, `tns`

## Planned follow-up

- continue splitting broad workflow helpers into smaller purpose-based files where helpful
- add a repo help command that can summarize modules and exported commands by category
- review shell and editor color choices against the final portable theme direction
