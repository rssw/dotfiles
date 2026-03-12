# Window navigation and manipulation.

unbind-key p
unbind-key n
bind-key p previous-window
bind-key n next-window
bind-key -n C-PageUp previous-window
bind-key -n C-PageDown next-window
bind-key -n M-h previous-window
bind-key -n M-l next-window

unbind-key M-p
unbind-key M-n
unbind-key l
unbind-key 0
unbind-key 1
unbind-key 2
unbind-key 3
unbind-key 4
unbind-key 5
unbind-key 6
unbind-key 7
unbind-key 8
unbind-key 9

run-shell 'if echo $TMUX | grep -q tmux; then executable=tmux; else executable=tmate; fi; $executable setenv -g TMUX_VERSION $($executable -V | sed -En "s/^$executable ([0-9]+(.[0-9]+)?).*/\1/p"); $executable setenv -g TMUX_EXE $executable'
if-shell -b '[ $(printf "%d" "$TMUX_VERSION") -ge 3 ]' " \
	bind-key -n M-PageUp { swap-window -t -1; previous-window }; \
	bind-key -n M-PageDown { swap-window -t +1; next-window }; \
	bind-key -n C-S-PageUp { swap-window -t -1; previous-window }; \
	bind-key -n C-S-PageDown { swap-window -t +1; next-window }" " \
	bind-key -n M-PageUp swap-window -t -1; \
	bind-key -n M-PageDown swap-window -t +1; \
	bind-key -n C-S-PageUp swap-window -t -1; \
	bind-key -n C-S-PageDown swap-window -t +1"

unbind-key .
unbind-key ,
bind-key , command-prompt -I "rename-window "

unbind-key '"'
bind-key v split-window -v -c '#{pane_current_path}'
unbind-key %
bind-key h split-window -h -c '#{pane_current_path}'

unbind-key c
bind-key c new-window -c '#{pane_current_path}'
bind-key -n M-n new-window -c '#{pane_current_path}'
unbind-key N
unbind-key &

unbind-key C-o
bind-key r rotate-window -U
unbind-key M-o
bind-key R rotate-window -D

set-option -g automatic-rename-format '#{b:pane_current_path} :: #{pane_current_command}'
