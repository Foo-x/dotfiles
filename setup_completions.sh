#!/bin/sh

fetch() {
  if type "$1" > /dev/null 2>&1; then
    if [ ! -f "$1.completion.bash" ]; then
      curl -fsSL "$2" -o "$1.completion.bash"
    fi
  fi
}

create() {
  if type "$1" > /dev/null 2>&1; then
    if [ ! -f "$1.completion.bash" ]; then
      eval "$2" > "$1.completion.bash"
    fi
  fi
}

cd $(dirname ${BASH_SOURCE:-$0})
mkdir -p completion
cd completion

fetch git https://github.com/git/git/raw/master/contrib/completion/git-completion.bash
fetch tmux https://raw.githubusercontent.com/Bash-it/bash-it/master/completion/available/tmux.completion.bash
fetch bun https://raw.githubusercontent.com/oven-sh/bun/main/completions/bun.bash

create f 'f completion'
create rustup 'rustup completions bash'
create cargo 'rustup completions bash cargo'
create gh 'gh completion -s bash'
create npm 'npm completion'
create docker 'docker completion bash'
create mise 'mise completion bash'
create zoxide 'zoxide init bash'
create just 'just --completions bash'
