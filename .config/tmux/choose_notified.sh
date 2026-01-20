#!/usr/bin/env bash

if [ -n "$(tmux list-panes -af '#{==:#{@tmux_notification},1}')" ]; then
  tmux choose-tree -Z -f "#{==:#{@tmux_notification},1}"
else
  tmux display-message "No matching items found"
fi
