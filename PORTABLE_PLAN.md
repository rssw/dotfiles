# Portable Dotfiles Plan

**Purpose**: Architecture decisions, design rationale, and implementation planning for this dotfiles repository.

**For users**: See [INSTALL.md](INSTALL.md) for installation instructions.  
**For developers**: See [AGENTS.md](AGENTS.md) for code style and conventions.

---

**Goal**: Turn the previous organic dotfiles setup into a portable, headless-first system that can be installed on new machines with one command, while remaining easy to understand and edit by hand.

This file holds design decisions and context needed to resume development without losing intent.

## Current direction

- keep the repo shell-first and terminal-first
- preserve the existing zsh + tmux + Neovim workflow where it is good, but refactor it into a clearer portable architecture
- separate standard defaults from optional integrations and local/private overlays
- design the final setup for headless machines first, while still supporting richer local terminals

## Accepted development goals

- keep the deployment flow repo-driven: compose scripts and docs for new-machine setup without changing the current machine as part of development
- keep bootstrap non-destructive by default, with dry-run verification and explicit conflict-handling choices
- treat machine-local identity, credentials, and secret lookup as post-install follow-up rather than tracked repo state
- provide both a simple guided local-setup helper and a checklist for per-machine completion steps
- make the final environment discoverable with an in-repo help command, not just scattered docs
- keep the active repo tree focused on files that directly support the documented install outcomes; archive the rest

## Current outcomes

- `bootstrap.sh` now installs packages, initializes submodules, links the portable subset, seeds local templates, and supports `--dry-run` plus `--backup-existing`
- `verify-bootstrap.sh` now provides repeatable syntax checks, config smoke tests, and isolated bootstrap dry-runs
- `verify-bootstrap.sh` now skips tool-specific checks cleanly when prerequisite commands are not installed yet
- shell config is split into `/.shell/core/`, `/.shell/optional/`, and `/.shell/local/`
- tmux, Neovim, and Git docs/config now follow a clearer portable-vs-local architecture
- machine-local templates and helpers now exist for Git and mail setup (`msmtp`, mutt/neomutt)
- a portable base `.muttrc` is part of the managed surface, while account-specific identity stays local in `~/.local/share/mutt/private.rc`; mailbox synchronization remains a separate concern
- post-install support now includes `post-install-checklist`, `setup-local-machine`, and `dotfiles-help`
- non-install-surface tracked config is being moved under `/.archive/` so the active tree matches the bootstrap footprint
- the remaining shell/editor visual follow-up is to review colorscheme alignment across prompt, terminal, tmux, and Neovim
- language-server package installation is intentionally deferred until there is a curated cross-ecosystem profile worth standardizing in bootstrap
- Vaultwarden-backed Bitwarden CLI support is now part of the standard full interactive environment, with local mirrored secrets as the preferred path for unattended jobs

## Settled decisions

### Shell

- primary shell: `zsh`
- fallback shell: `bash`
- keep `powerlevel10k`
- do not migrate to `starship`
- do not adopt `oh-my-zsh`
- keep explicit/manual zsh plugin loading instead of adding a framework
- standard shell plugins/tools:
  - `powerlevel10k`
  - `zsh-syntax-highlighting`
  - `zsh-autosuggestions`
  - `fzf`
  - `fzf-tab`
  - `direnv`
- `nala` belongs to the default full profile, not the minimal baseline
- if `nala` is installed, alias `apt` to `nala`
- `fd-find` should be normalized to `fd` when available on Debian-family systems

### Tmux

- keep tmux prefix as `C-s`
- keep tmux as part of the standard environment

### Neovim

- keep trust-sensitive features enabled by default (`localvimrc`, privileged-edit support if retained)
- nonstandard word-motion remaps should not be the default; they should become optional
- split/pane navigation should align with tmux
- add Neovim split resize mappings from the start

### Mail and scripts

- local-only scripts should live in `~/bin`
- shared tracked scripts should be exposed via `~/bin/shared`
- actual script review/import happens after the core dotfiles are working
- Mailutils / Mailu support remains in scope, but active debugging of mail sending is deferred
- `msmtp` should be the backend mail transport for scripts and notifications
- `mutt` should remain an optional interactive mail client layered on top

### Help/discovery

- keep a repo-provided help command/script in the repo for deployed-machine orientation
- the help command should summarize:
  - custom shell aliases/functions by category
  - tmux key changes
  - Neovim key changes and optional layers
  - package-aware optional integrations

## Cross-application shortcut policy

The main design constraint is that Neovim frequently runs inside tmux. Shortcuts must therefore respect overlap and keep the same semantic meaning across tools whenever practical.

### House rules

- `Ctrl-h/j/k/l` means move focus to the adjacent pane or split
- `Alt-h/l` means move to the previous or next higher-level container
- `Alt-Arrow` means resize the current pane or split directionally
- native fallback commands remain available and documented

### Concrete mapping policy

- `tmux`
  - `Ctrl-h/j/k/l`: move between panes
  - `Alt-h/l`: previous/next window
  - `Alt-Arrow`: resize pane
- `Neovim`
  - `Ctrl-h/j/k/l`: move between splits
  - `Alt-h/l`: previous/next buffer
  - `Alt-Arrow`: resize split
  - keep native fallbacks such as `Ctrl-w` and `gt/gT`
- `Neovim inside tmux`
  - tmux should pass `Ctrl-h/j/k/l` through when the active pane is Neovim, so the same keys still move inside Neovim first

### Important implication

- word-motion remaps in Neovim are a separate concern from pane/split navigation and should not drive cross-application navigation design

### Rationale and comparison to the previous approach

- the previous approach already aligned `tmux` and Neovim for adjacent pane/split movement with `Ctrl-h/j/k/l`
- the previous approach already used `Alt-h/l` for tmux window switching and `Alt-Arrow` for tmux pane resizing
- the previous approach did not extend that same higher-level navigation model into Neovim buffers, so part of the new policy is an intentional completion of an existing design direction rather than a reversal
- likely reasons the previous approach stopped there:
  - adjacent pane/split movement is the highest-frequency pain point when Neovim runs inside tmux
  - tmux-to-Neovim pass-through for `Ctrl-h/j/k/l` solves the biggest nested-terminal friction first
  - leaving Neovim buffers and tabs closer to native behavior avoids over-customizing Vim's non-spatial navigation model
- likely reasons the previous approach chose these custom bindings instead of defaults:
  - tmux prefix-heavy defaults are slower for frequent movement
  - directional `hjkl` bindings fit vi-style muscle memory already used elsewhere in the repo
  - plain letter modifiers are often more portable than some function-key or modified-arrow combinations across SSH, tmux, and terminals
- likely terminal/client conflicts the previous approach may have been avoiding:
  - shell/readline use of `Ctrl-p/n` for history movement
  - inconsistent handling of Home/End/Delete and some modified special keys across terminals
  - Windows and WSL terminal layers, where some key combinations can be translated or dropped before reaching tmux or Neovim
  - terminal-emulator tab shortcuts that often use PageUp/PageDown or other common key families
- design conclusion for this repo:
  - keep the previous `Ctrl-h/j/k/l` pane/split policy
  - preserve native fallbacks
  - extend the house policy to Neovim buffers and split resizing only where it improves consistency without creating common terminal conflicts

## Package tiers

The install system should support both package-level flags and group-level flags.

### Required packages

- `zsh`
- `bash`
- `git`
- `less`
- `direnv`
- `fzf`
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- `neovim`
- `tmux`
- `ripgrep`
- `fd-find`
- `jq`
- `fastfetch`
- `pv`
- `p7zip`
- `unzip`
- `cifs-utils`
- `exfatprogs`
- `nfs-common`

### Optional packages

- `nala`
- `mutt`
- `lf`
- clipboard tools such as `wl-clipboard`, `xclip`, or `xsel`
- `taskwarrior`
- `gpg` and pinentry tools
- Mailutils / Mailu-related tools later

### Nerd font policy

- nerd fonts do not need to be installed on headless machines
- preserve an ASCII / no-icons fallback for remote or limited terminals
- document when the richer prompt appearance depends on local terminal font support

## Installer behavior

### Default mode

- if the user supplies no install options, perform a full install
- full install means:
  - install required packages
  - install optional packages selected for the default full profile
  - initialize needed submodules
  - link configuration files
  - prepare local directories

### Flag model

- support package-level flags for specific optional features
- support group-level include/exclude flags such as:
  - `--full`
  - `--minimal`
  - `--no-mail`
  - `--no-extra-shell`
  - `--with-nala`
  - `--without-nala`
  - `--with-mutt`
  - `--without-mutt`
  - `--with-lf`
  - `--without-lf`
  - `--with-taskwarrior`
  - `--without-taskwarrior`
- exact flag names can be finalized during implementation, but both per-feature and per-group controls are required

### Platform/package-manager behavior

- start with Debian/Ubuntu-family machines as the first-class install target
- detect package naming differences where needed (for example `fd-find`)
- add external package sources only when needed for selected packages (for example Fastfetch on Ubuntu releases that do not ship it yet)
- if promoting Neovim to the default `vi`/`vim` experience, check for and remove `vi-tiny` if required and if it will not be handled automatically by package replacement logic
- keep bootstrap package groups capability-oriented so it is easy to understand what the standard environment guarantees on every machine

## Planned shell architecture

### Standard shell files

- `/.zshenv`
  - environment policy
  - PATH construction
  - editor/pager policy
  - package-aware binary normalization such as `fd`
- `/.zshrc`
  - completion, history, zle, keybindings, prompt, plugin loading
  - startup ordering must be documented
- `/.bashrc`
  - compatibility layer, not an independent full personality
- `/.zlogin`
  - local login-time include points

### Shell module split

- refactor `/.shell/` into clearer categories, for example:
  - `/.shell/core/`
  - `/.shell/optional/`
  - `/.shell/local/` or documented external local include points
- split the current large `/.shell/shortcuts` file into purpose-based files so both humans and the future help script can understand them

### Standard shell behaviors

- keep shared PATH/editor/pager setup
- keep zsh completion and history setup
- keep vi-mode shell editing
- keep `fzf`, `fzf-tab`, syntax highlighting, autosuggestions, and `direnv`
- keep `powerlevel10k`
- keep package-aware aliasing such as `apt -> nala` only when the relevant package exists

### Optional shell behaviors

- taskwarrior cwd/context hooks
- `lf` integration if `lf` is installed
- mail-related helpers if optional mail tooling is installed
- clipboard-specific helpers if clipboard tools are installed
- other workflow-specific or service-specific helpers

### Local/private shell behaviors

- host-specific env files
- login overlays for host or OS
- private credentials and service-specific settings
- private note paths and private host automation

## Planned tmux architecture

- retain existing pane navigation with `Ctrl-h/j/k/l`
- retain existing window navigation with `Alt-h/l`
- retain resize with `Alt-Arrow`
- document the current custom workflow clearly:
  - prefix key
  - split creation
  - pane movement
  - window movement
  - layout switching
  - copy mode and clipboard backends

## Planned Neovim architecture

Refactor Neovim into explicit layers:

- base terminal profile
- standard plugin layer
- optional advanced plugin layer
- local/host overlay

### Neovim defaults to keep

- terminal-first base configuration
- tmux-aware split navigation
- trust-sensitive features enabled by default, but documented clearly

### Neovim changes to make

- move nonstandard word-motion remaps into an optional layer
- add `Alt-h/l` for previous/next buffer
- add `Alt-Arrow` resize mappings for splits from the start
- reduce dependence on machine-name overlays for the standard experience
- document base vs optional behavior clearly

## Git architecture

- keep the global ignore baseline
- rebuild the previous git configuration around the actual user identity and workflow
- separate portable git defaults from local/private identity and service-specific settings

## Documentation strategy

The final configuration should be easy to maintain manually.

### Required documentation structure

- a top-level install/bootstrap document
- a post-install guide or simple post-install checklist command for machine-local follow-up
- domain-level docs for:
  - shell
  - tmux
  - Neovim
  - git
- top-of-file guidance blocks in the main config files

### Each major config file should explain

- what the file controls
- whether it is standard, optional, or local/private
- common changes to make there
- notable dependencies
- where local overrides belong

### Post-install guidance requirements

- after bootstrap, provide a clear follow-up path for machine-local values that cannot live in git
- acceptable approaches:
  - a post-install checklist that points to the files that must be edited
  - a simple guided prompt script that writes local template files without storing secrets in git
- initial focus should cover:
  - git identity
  - mail identity and SMTP settings
  - local auth/bootstrap steps such as `gh auth login`
- keep this intentionally simple; a checklist is preferable to a complicated secret manager integration at first

## Help command requirements

Late in implementation, add a repo-provided help command that summarizes the final customized environment.

### Help command content

- shell aliases/functions by category
- git aliases and workflow helpers
- tmux custom keys and the house movement policy
- Neovim custom keys, especially navigation and optional motion layers
- optional feature availability based on installed tools

### Help command design goals

- application-oriented output rather than a raw dump
- easy to skim in a terminal
- stable enough to remain accurate after future edits

## Follow-up work after core dotfiles are stable

- review `~/bin` and move safe personal scripts into tracked `bin/`
- keep risky, destructive, or secret-bearing scripts local until sanitized
- restore Mailutils / Mailu support in a documented, secret-safe way
- refine the `msmtp` + mutt/neomutt mail workflow and documentation as the real deployment path settles

## Implementation order

1. finalize installer package groups and flag model
2. refactor shell layout into standard / optional / local-private layers
3. clean shell startup order and document it
4. add package-aware shell integrations (`apt -> nala`, `fd`, etc.)
5. document shell files and behaviors thoroughly
6. refactor and document tmux under the cross-application shortcut policy
7. refactor and document Neovim into explicit layers with aligned navigation
8. rewrite git config around the actual user profile
9. implement bootstrap/install scripts with full-install default and group flags
10. revisit `~/bin` and mail integration
11. add post-install follow-up guidance or a simple guided local-setup helper
12. add the final help command/script
13. review docs against the implemented deployment flow and prune stale planning notes

## Notes for future execution

- the current repo already has a good directional navigation foundation:
  - tmux pane movement uses `Ctrl-h/j/k/l`
  - Neovim split movement uses `Ctrl-h/j/k/l`
- the next execution phase should preserve that alignment and extend it to Neovim buffer cycling and split resizing
- if interrupted, resume from this file and continue from the implementation order above
