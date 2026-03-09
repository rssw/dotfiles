# Git Config

This directory now separates portable Git defaults from machine-local identity.

- `config`
  - tracked portable defaults: editor/pager policy, aliases, diff/merge tools, URL shortcuts, colors, and shared behavior
  - includes `~/.local/share/git/config` for local identity and credentials
- `ignore`
  - global ignore baseline shared across machines
- `local.example`
  - template for `~/.local/share/git/config`
  - copy and customize for user name, email, credential usernames, mail settings, and machine-specific includes

The bootstrap script links `~/.config/git` and creates `~/.local/share/git/config` from the template if it does not exist yet.
