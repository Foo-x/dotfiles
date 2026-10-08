#!/usr/bin/env bash

event="${1:-}"
input="$(cat)"

set_state() { tmux set -p -t "${TMUX_PANE}" @claude_state "$1"; }
notify() { tmux set -p -t "${TMUX_PANE}" @tmux_notification 1; }

session_id="$(jq -r '.session_id // empty' <<<"$input")"
agent_id="$(jq -r '.agent_id // empty' <<<"$input")"

# サブエージェントの並列終了で競合しないよう、agent_id ごとのファイルで数える
dir="${XDG_RUNTIME_DIR:-/tmp}/claude-state/${session_id:-unknown}"
mkdir -p "$dir/agents"

running() { [ -n "$(ls -A "$dir/agents")" ]; }

finish_if_idle() {
  if [ -e "$dir/stopped" ] && ! running; then
    notify
    set_state 'v done   '
  fi
}

case "$event" in
  session-start)
    rm -rf "$dir"
    mkdir -p "$dir/agents"
    set_state '- idle   '
    ;;
  working)
    rm -f "$dir/stopped"
    set_state '> working'
    ;;
  permission)
    notify
    set_state '! blocked'
    ;;
  subagent-start)
    [ -n "$agent_id" ] && touch "$dir/agents/$agent_id"
    rm -f "$dir/stopped"
    set_state '> working'
    ;;
  subagent-stop)
    [ -n "$agent_id" ] && rm -f "$dir/agents/$agent_id"
    finish_if_idle
    ;;
  stop)
    touch "$dir/stopped"
    finish_if_idle
    ;;
esac
