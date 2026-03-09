Tracked home-bin scripts live here.

Goal:
- keep personal command-line helpers in the repo
- expose them via `~/bin` on installed machines
- separate portable scripts from private or machine-specific ones

Current status:
- safe, generic scripts can live here directly
- private or production-tied scripts should stay out of git or be sanitized first
- environment helper scripts now include `post-install-checklist`, `setup-local-machine`, and `dotfiles-help`

Planned install behavior:
- link `~/bin` to `DOTFILES_DIR/bin`
- keep `DOTFILES_DIR/.bin` for repo-internal helper commands
