# Related Config

This directory stores tracked configuration files that are related to this
environment but are not part of the active bootstrap or symlinked install
surface.

Use it for things like:
- terminal emulator configs managed on another host or OS
- reference themes and color files
- machine-adjacent configs you want in git without wiring into `bootstrap.sh`

Rules:
- files here are documentation/reference unless explicitly promoted later
- nothing here is linked automatically by `bootstrap.sh`
- if a config becomes part of the managed install surface, move it into the
  active repo tree and update docs/scripts accordingly
