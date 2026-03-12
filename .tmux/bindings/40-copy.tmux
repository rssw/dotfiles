# Copy mode and clipboard integration.

unbind-key [
unbind-key PageUp
bind-key -n M-c copy-mode
if-shell 'type xclip && [[ "$TMUX_EXE" == tmux ]]' \
	'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"'
if-shell 'type xsel && [[ "$TMUX_EXE" == tmux ]]' \
	'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xsel -bi"'
if-shell 'type wl-copy && [[ "$TMUX_EXE" == tmux ]]' \
	'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"'
if-shell 'type clip.exe && [[ "$TMUX_EXE" == tmux ]]' \
	'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "clip.exe"'
if-shell '[[ "$TMUX_EXE" == tmate ]]' \
	'set-environment -g TMUX_URL_SELECT_TMUX_CMD tmate'
if-shell '[[ "$TMUX_EXE" == tmate ]] || $TMUX_EXE list-keys -T copy-mode-vi | grep -q -E "(xsel|xclip|wl-copy|clip.exe)"' \
	'' \
	'bind-key -T copy-mode-vi y display-message "Error: Nor xclip / xsel / wl-copy are installed"'
unbind-key ]
bind-key -n M-- run-shell ~/.local/bin/tmux-url-select
bind-key -n M-p paste-buffer

bind-key -T copy-mode-vi e send-keys -X next-word
bind-key -T copy-mode-vi w send-keys -X previous-word
bind-key -T copy-mode-vi E send-keys -X next-space
bind-key -T copy-mode-vi W send-keys -X previous-space

unbind-key '#'
bind-key @ show-buffer
unbind-key =
bind-key '"' choose-buffer
