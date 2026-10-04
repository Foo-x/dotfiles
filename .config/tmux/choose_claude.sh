#!/usr/bin/env bash

port=6266

if [ "${1:-}" = list ]; then
  tmux list-panes -a -f '#{m:*claude*,#{pane_current_command}}' \
    -F '#{?@claude_state,#{@claude_state},? unknown} #{session_name}:#{window_index}.#{pane_index} #{pane_current_path}' \
  | awk '
    { s = $1 " " $2; c = "" }
    s == "- idle"    { c = "97" }
    s == "> working" { c = "33" }
    s == "! blocked" { c = "31" }
    c != "" { $0 = "\033[" c "m" s "\033[0m" substr($0, length(s) + 1) }
    { print }'
  exit
fi

cmd="'$0' list"

(while sleep 1; do
  curl -s -XPOST "127.0.0.1:$port" -d "reload($cmd)+refresh-preview" >/dev/null || break
done) &

eval "$cmd" \
| fzf --reverse --ansi --listen "127.0.0.1:$port" \
    --track --id-nth 3 \
    --preview 'tmux capture-pane -ep -t {3}' \
    --preview-window 'right:60%:follow' \
| awk '{ print $3 }' \
| xargs -r tmux switch-client -t
