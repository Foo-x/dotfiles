DOT_DIR="${HOME}/.dotfiles"

shopt -s autocd
shopt -s cdspell
shopt -s dirspell
shopt -s extglob
shopt -s globstar
shopt -s nocaseglob
shopt -s nocasematch
shopt -s nullglob
shopt -u histappend
shopt -s histreedit
shopt -s histverify

eval "$(devbox global shellenv --init-hook)" 2> /dev/null

. ${DOT_DIR}/.config/bash/.aliases
. ${DOT_DIR}/.config/bash/.exports
. ${DOT_DIR}/.config/bash/.aliases_cdb

complete -C terraform terraform
complete -C terraform tf

. ${DOT_DIR}/.config/bash/complete_alias

eval "$(zoxide init bash --cmd cd)"

if [ -d ${HOME}/.fzf-tab-completion ]; then
  function _lazy_fzf_bash_completion() {
    if ! type fzf_bash_completion &> /dev/null; then
      . ${HOME}/.fzf-tab-completion/bash/fzf-bash-completion.sh
    fi
    fzf_bash_completion
  }
  # bind S-tab to fzf bash completion
  bind -x '"\e[Z": _lazy_fzf_bash_completion'
fi

function _lazy_complete() {
  if alias | cut -c7- | \grep -q "^$1="; then
    if [[ $1 == 'j' ]]; then
      . <(jj util completion bash)
    fi
    if [[ $1 == 'deb' ]]; then
      . <(devbox completion bash)
    fi
    complete -F _complete_alias "$1"
    return 124
  fi
  if [[ $1 == 'jj' ]]; then
    . <(jj util completion bash)
    return 124
  fi
  if [[ $1 == 'devbox' ]]; then
    . <(devbox completion bash)
    return 124
  fi
  if [ -f "${DOT_DIR}/completion/$1.completion.bash" ]; then
    . "${DOT_DIR}/completion/$1.completion.bash" &> /dev/null
    return 124
  fi
  if [ -f "/usr/share/bash-completion/completions/$1" ]; then
    . "/usr/share/bash-completion/completions/$1" &> /dev/null
    return 124
  fi
}

complete -D -F _lazy_complete -o bashdefault -o default

if type tmux &> /dev/null; then
  if [[ -z ${TMUX} && ${TERM_PROGRAM} != 'vscode' ]]; then
    while ! tmux new -A &> /dev/null; do sleep 0.2; done
  fi
fi
