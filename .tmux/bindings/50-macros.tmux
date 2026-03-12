# Higher-level helpers and reload hooks.

bind-key E command-prompt -p "Command:" \
	"run  \"tmux list-sessions                  -F '##{session_name}'        | xargs -I SESS \
			tmux list-windows  -t SESS          -F 'SESS:##{window_index}'   | xargs -I SESS_WIN \
			tmux list-panes    -t SESS_WIN      -F 'SESS_WIN.##{pane_index}' | xargs -I SESS_WIN_PANE \
			tmux send-keys     -t SESS_WIN_PANE '%1' Enter\""

bind-key R display 'sourcing ~/.tmux.conf' \; source-file ~/.tmux.conf
