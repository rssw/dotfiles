# Pane navigation and manipulation.

unbind-key Up
unbind-key Down
unbind-key Left
unbind-key Right

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n C-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
bind-key -n C-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
bind-key -n C-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
bind-key -T copy-mode-vi C-h select-pane -L
bind-key -T copy-mode-vi C-j select-pane -D
bind-key -T copy-mode-vi C-k select-pane -U
bind-key -T copy-mode-vi C-l select-pane -R

unbind-key q
unbind-key o
unbind-key C-Up
unbind-key C-Down
unbind-key C-Left
unbind-key C-Right
unbind-key M-Up
unbind-key M-Down
unbind-key M-Left
unbind-key M-Right
unbind-key M-h
unbind-key M-j
unbind-key M-k
unbind-key M-l

bind-key -n M-h resize-pane -L
bind-key -n M-j resize-pane -D
bind-key -n M-k resize-pane -U
bind-key -n M-l resize-pane -R
bind-key | resize-pane -x 200
bind-key _ resize-pane -y 200

bind-key j command-prompt -p "create pane from:" "join-pane -s ':%%'"
unbind-key !
bind-key b break-pane
unbind-key x
bind-key -n M-q confirm-before -p "kill-pane #P? (y/n)" kill-pane

unbind-key space
bind-key -n M-space next-layout
unbind-key M-1
unbind-key M-2
unbind-key M-3
unbind-key M-4
unbind-key M-5
