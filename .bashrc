SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

shopt -s autocd
shopt -s cdspell
shopt -s dirspell
shopt -s extglob
shopt -s globstar
shopt -s nocaseglob
shopt -s nocasematch
shopt -s nullglob
shopt -u histappend

# set CapsLock to Ctrl if setxkbmap exists
if [ "$(uname)" != 'Darwin' ] && type setxkbmap &> /dev/null; then
  setxkbmap -option ctrl:nocaps
fi

. ${SCRIPT_DIR}/.aliases
. ${SCRIPT_DIR}/.exports
. ${SCRIPT_DIR}/.git-completion

if type pacman &> /dev/null; then
  . ${SCRIPT_DIR}/.aliases_arch
fi

if type fzf &> /dev/null; then
  . ${SCRIPT_DIR}/.aliases_fzf
fi

if type tmux &> /dev/null; then
  . ${SCRIPT_DIR}/tmux.completion.bash

  if [[ ${SHLVL} == 1 ]]; then
    tmux new -A -s $(basename $(pwd) | tr -d .)
  fi
fi

. ${SCRIPT_DIR}/complete_alias
