# Install

This repo is being refactored into a portable, headless-first dotfiles setup.

The current bootstrap entrypoint is `./bootstrap.sh`.

## Default behavior

Running `./bootstrap.sh` is intended to:

- install required packages for Debian/Ubuntu-family systems
- install the default optional package set for the full profile
- initialize git submodules
- symlink repo-managed config into `HOME`
- prepare local state directories under `~/.local/share/`

The current full profile includes `nala`, mail tooling (`mutt` and `msmtp`),
`lf`, `taskwarrior`, Bitwarden CLI, clipboard tools, and GPG helpers.

Bootstrap groups packages by capability so the standard environment is easier to
reason about everywhere: core shell, prompt/fonts, navigation/search, editor,
system/storage support, and a small set of optional feature groups.

## Standard environment

The baseline environment that bootstrap tries to make available everywhere is:

- shell/core CLI: `zsh`, `bash`, `git`, `less`, `curl`
- prompt/fonts: `fontconfig`, MesloLGS NF download, `fonts-firacode`, `fonts-jetbrains-mono`
- navigation/search: `direnv`, `fzf`, `ripgrep`, `fd-find`, `jq`, `pv`, `p7zip-full`, `unzip`
- editor/terminal: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `neovim`, `tmux`
- system/storage support: `cifs-utils`, `exfatprogs`, `nfs-common`, `fastfetch`

The default full profile adds:

- package QoL: `nala`
- mail: `mutt`, `msmtp`
- file manager: `lf`
- productivity: `taskwarrior`
- secret manager CLI: pinned Bitwarden CLI configured for the hosted Vaultwarden server
- extra shell integrations: `wl-clipboard`, `xclip`, `xsel`, `gpg`, `pinentry-curses`

Existing target paths are skipped by default. Use `--backup-existing` to move
conflicting files aside before linking or templating.

## Safe first run

Preview actions without changing the machine:

```sh
./bootstrap.sh --dry-run
```

Run a smaller baseline install:

```sh
./bootstrap.sh --minimal
```

Example full install without mail extras:

```sh
./bootstrap.sh --full --no-mail
```

## Verification

Run the lightweight verification harness before changing the bootstrap logic:

```sh
./verify-bootstrap.sh
```

This runs syntax checks, config smoke checks, and `bootstrap.sh` dry-run checks
against throwaway `HOME` directories so the current machine is not modified.
Checks that depend on optional tools such as `zsh`, `nvim`, or `tmux` are
skipped with a note when those commands are not installed yet.

To check whether the current machine's managed deployment still matches what
bootstrap would link for the selected profile, run:

```sh
./bootstrap.sh --verify
```

This compares repo-managed linked paths only. It stays quiet for matches and
prints diffs or missing-path notices for mismatches. Machine-local seeded files
such as Git identity and mail templates are intentionally excluded.

## Post-install follow-up

After bootstrap, run the lightweight checklist:

```sh
post-install-checklist
```

This reports which local files still need customization and reminds you about
manual steps such as terminal font selection, GitHub auth, zkbd key discovery,
mail setup, and a test mail send.

For a quick orientation to the installed environment, run:

```sh
dotfiles-help
```

This prints the house keybindings, config layering, and the main local files to
edit after install.

If you want a simple guided helper for the most common local values, run:

```sh
setup-local-machine
```

This writes machine-local Git, `msmtp`, and optional mutt/neomutt config files
without storing secrets in the repo.

If you use the hosted Vaultwarden instance, the default full profile also
installs a pinned Bitwarden CLI release that is known to work with it,
configures the CLI server URL, and provides helper commands:

- `bw-session login`
- `bw-session unlock`
- `bw-session status`
- `bw-session test`
- `secret-sync`
- `secret-read NAME`
- `bw-pass ITEM_ID`

When present, `~/.local/share/bitwarden/session.env` is loaded automatically by
interactive shells so saved Bitwarden sessions are available in new terminals.
Shell startup stays quiet; `bw-pass` and `bw-session test` are the intended
places to detect and report expired or missing sessions.

For the current hosted Vaultwarden deployment, `bw-session unlock` is treated as
the practical "get me a usable session" command and uses the login flow that is
known to succeed reliably with this CLI/server combination.

At the end of a real install, bootstrap attempts to change the current user's
login shell to `zsh` and then starts a `zsh` login shell for the current
session when you launched it from another interactive shell.

## Supported flags

- profiles: `--full`, `--minimal`
- feature toggles:
  - `--with-nala`, `--without-nala`
  - `--with-mutt`, `--without-mutt`
  - `--with-lf`, `--without-lf`
  - `--with-taskwarrior`, `--without-taskwarrior`
  - `--with-bitwarden`, `--without-bitwarden`
  - `--no-mail`
  - `--no-extra-shell`
  - `--backup-existing`
- execution controls:
  - `--no-packages`
  - `--no-submodules`
  - `--no-link`
  - `--verify`
  - `--dry-run`

## Notes

- package installation currently assumes `apt-get` on Debian/Ubuntu-family systems
- bootstrap installs the MesloLGS NF Powerlevel10k font into `~/.local/share/fonts`
  and refreshes the font cache when possible; it also installs `fonts-firacode`
  and `fonts-jetbrains-mono` from apt so you have common terminal font choices
- on Ubuntu 22.04+ the bootstrap adds the Fastfetch PPA automatically when
  `fastfetch` is selected but not available from the current apt sources
- `msmtp` is the intended backend mail transport for scripts and server notifications
- `mutt`/`neomutt` is the optional interactive mail client layer on top of that transport
- the default full profile installs Bitwarden CLI `2026.1.0` from GitHub because newer releases are not currently compatible with the hosted Vaultwarden deployment
- language-server binaries are not installed by bootstrap today; Neovim enables LSP clients only when the matching server executable is already present on the machine
- bootstrap seeds local mail templates when missing:
  - `~/.config/msmtp/config` from `.config/msmtp/config.example`
  - `~/.local/share/mutt/private.rc` from `.archive/.mutt/private.rc.example`
- existing files are not overwritten during linking; conflicting paths are skipped with a warning
- `~/.config/` is merged entry-by-entry instead of replacing the whole directory
- only a conservative portable subset of `/.config/` is linked automatically for now
- `/.shell/local/` is reserved for machine-local overrides and stays untracked
- Git identity stays local: bootstrap seeds `~/.local/share/git/config` from `.config/git/local.example` when missing

## Current portable config subset

The bootstrap currently auto-links these `~/.config` entries:

- `direnv`
- `gh`
- `git`
- `htop`
- `lf`
- `nvim`
- `pip`

Tracked config that is not part of the current install surface has been moved
under `/.archive/` instead of staying mixed into the active deployment tree.

`gh` is now part of the portable subset, but GitHub authentication remains
local. The repo tracks `/.config/gh/config.yml` for defaults and ships
`/.config/gh/hosts.yml.example` as a reference only.

## Current root-level link subset

The bootstrap currently links these root-level entries into `HOME`:

- shell startup and shared shell layers: `.bashrc`, `.shell`, `.zlogin`, `.zsh`, `.zshenv`, `.zshrc`
- editor and terminal workflow: `.config`, `.tmux`, `.tmux.conf`, `.vim`, `.vimrc`, `.p10k.zsh`, `.terminfo`, `.muttrc`
- supporting data and helpers: `.bin`, `bin` (installed as `~/bin/shared`), `.infokey`, `.inputrc`, `.pam_environment`

Why these remain in the deployment target:

- `.p10k.zsh`
  - prompt policy for the interactive Zsh environment
  - still part of the intended terminal UX
  - linked into `HOME`, so `p10k configure` updates the tracked repo file on installed machines
- `.pam_environment`
  - login-session defaults such as pager behavior, `SSH_AUTH_SOCK`, and shared environment values
  - still useful for workstation/server login consistency
- `.infokey`
  - custom GNU Info keybindings
  - small, portable, and aligned with the terminal-first workflow
- `.inputrc`
  - readline defaults and vi-style history/search bindings
  - affects many shell-adjacent tools consistently
- `.muttrc`
  - portable base mutt/neomutt behavior plus a source line for local identity in `~/.local/share/mutt/private.rc`
  - avoids fallback to `/var/mail/$USER` and provides a readable baseline mail UI
- `.terminfo`
  - local terminal capability entries used by terminal/tmux/editor workflows
  - retained because terminal compatibility is part of the target environment
- `.bin` and `bin`
  - `.bin` holds repo-internal helper scripts
  - `bin` holds shared user-facing CLI helpers and is linked to `~/bin/shared`
  - `~/bin` itself remains available for machine-local scripts

These tracked root-level entries are currently outside the deployment target
footprint and have been archived under `/.archive/`:

- `.ncmpc`
- `.ncmpcpp`
- `.nyx`
- `.pandoc`
- `.texmf`
- `.tmate.conf`
- `.urxvt`
- `.w3m`

Additional non-install-surface config has also been archived there, including
desktop autostart entries, SSH host config, older desktop app configs, and
service-specific integrations that are not part of `bootstrap.sh` today.

Recently archived from the managed surface because they are too niche for the
standard environment guarantee:

- `octave`
- `mpv`
- `nix-init`
- `nixpkgs`
- `pistol`
- `pulse`
- `ranger`
- `rtv`
- `stig`
- `tox`
- `vifm`
- `vimfx`

## Local templates

Bootstrap now seeds a few machine-local files when they are missing:

- `~/.local/share/git/config`
  - from `.config/git/local.example`
- `~/.config/msmtp/config`
  - from `.config/msmtp/config.example`
  - preferred unattended lookup: `passwordeval ~/bin/shared/secret-read smtp-password`
  - direct Bitwarden lookup remains available: `passwordeval ~/bin/shared/bw-pass ITEM_ID`
- `~/.local/share/secret-mirror/items`
  - from `.config/secret-mirror/items.example`
  - format: `<local-name> <bitwarden-item-id>`
  - used by `secret-sync` to refresh cached secrets into `~/.local/share/secrets/`
- `~/.local/share/mutt/private.rc`
  - from `.archive/.mutt/private.rc.example`

These are intended for identity, account settings, and secret lookup commands.
They are not linked from the repo and should be customized per machine.
You can either edit them manually or generate them with `setup-local-machine`.

## Mail model

The current intended split is:

- `msmtp`
  - backend transport for scripts, alerts, and server-side notification workflows
  - should be configured first
  - secrets should stay in local secret lookup or local config only
  - do not rely on a Bitwarden session token alone for unattended scheduled jobs;
    use a non-interactive local secret source if mail must continue working after
    session expiry or restart
- `mutt` or `neomutt`
  - interactive mail client layer for reading/composing mail manually
  - should use `msmtp` as its sendmail path where possible
  - is not the primary transport abstraction for scripts
  - the tracked `.muttrc` now supplies a base UI, local Maildir defaults, and a source line for `~/.local/share/mutt/private.rc`

Suggested readiness checks after install:

- select `MesloLGS NF`, `FiraCode`, or `JetBrains Mono` in the terminal profile and restart the terminal
- run `zkbd` in a real zsh terminal if special keys still need terminal-specific bindings, then save the output as `~/.zkbd/$TERM`
- confirm the login shell changed to zsh with `getent passwd "$USER" | cut -d: -f7`
- confirm `~/.config/msmtp/config` has real host/user/from values
- confirm the `passwordeval` or other secret lookup command works on the machine
- if using `mail-rssw`, create `~/.local/share/mailutils/rssw.env` from the example and fill in real values
- send a test message through `msmtp` directly before relying on scripts
- if using mutt/neomutt, confirm its local identity file points at `msmtp`

## Conflict handling

Bootstrap currently supports two conflict behaviors:

- default `skip`
  - safest behavior
  - if a target file already exists, bootstrap leaves it alone and prints a warning
  - best when you are installing onto a machine that may already contain useful local state
- `--backup-existing`
  - cautious replacement behavior
  - if a target file already exists, bootstrap renames it to `*.bootstrap-backup.<timestamp>` and then installs the repo-managed link or template
  - best when you want the new environment shape applied automatically but still want rollback material preserved

Why the default is still `skip`:

- it avoids surprising changes on partially configured systems
- it reduces the chance of silently changing a working login or mail setup
- it keeps first runs conservative until the deployment footprint is fully settled

Why `--backup-existing` exists:

- it is more practical for migrating onto an already-used machine
- it preserves prior files for manual comparison or rollback
- it works for both linked repo files and seeded local templates

## Current gaps

- package selection still needs refinement as the portable profiles are finalized
- more repo paths still need explicit portable vs local/private classification
- conflict handling currently supports `skip` and `--backup-existing`, but not more advanced migration/merge behavior
- mail bootstrap now seeds templates and a guided local-setup helper exists; secret-manager-specific wiring beyond generic `passwordeval` remains future work
