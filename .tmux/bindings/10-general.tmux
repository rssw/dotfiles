# General tmux behavior that stays close to defaults.

unbind-key t
bind-key -n M-r command-prompt

unbind-key L
bind-key '$' command-prompt -I "rename-session "
