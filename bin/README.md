Tracked home-bin scripts live here.

Goal:
- keep personal command-line helpers in the repo
- expose them via `~/bin/shared` on installed machines
- separate portable scripts from private or machine-specific ones

Directory model:
- `~/bin`
  - local-only scripts for one machine
  - not managed by this repo
- `~/bin/shared`
  - symlink to tracked repo `bin/`
  - shared scripts intended to exist on installed machines

Current status:
- safe, generic scripts can live here directly
- private or production-tied scripts should stay out of git or be sanitized first
- environment helper scripts now include `post-install-checklist`, `setup-local-machine`, `dotfiles-help`, `tm`, `now`, `bw-session`, `bw-pass`, `secret-sync`, `secret-read`, and `vdiff`

Planned install behavior:
- create `~/bin` if missing and keep it for local-only scripts
- link `~/bin/shared` to `DOTFILES_DIR/bin`
- keep `DOTFILES_DIR/.bin` for repo-internal helper commands
