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

. ${DOT_DIR}/.config/bash/.aliases
. ${DOT_DIR}/.config/bash/.exports
. ${DOT_DIR}/.config/bash/.aliases_cdb

complete -C terraform terraform
complete -C terraform tf

. ${DOT_DIR}/.config/bash/complete_alias

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
    complete -F _complete_alias "$1"
    return 124
  fi
  . "${DOT_DIR}/completion/$1.completion.bash" &> /dev/null && return 124
}

complete -D -F _lazy_complete -o bashdefault -o default

if type tmux &> /dev/null; then
  if [[ -z ${TMUX} && ${TERM_PROGRAM} != 'vscode' ]]; then
    if [[ ${IS_WSL} == 1 ]] && ! \grep -iq 'appendWindowsPath *= *false' /etc/wsl.conf; then
      while ! [[ "$PATH" =~ '/mnt/c/windows/system32' ]]; do sleep 0.2; done
    fi
    while ! tmux attach &> /dev/null; do sleep 0.2; done
  fi
fi
