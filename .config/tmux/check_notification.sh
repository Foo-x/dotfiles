#!/usr/bin/env bash

if [ -n "$(tmux list-panes -a -f "#{@tmux_notification}")" ]; then
  echo "󰂚"
fi
