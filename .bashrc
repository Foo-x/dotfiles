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

if type pacman &> /dev/null; then
  . ${SCRIPT_DIR}/.aliases_arch
fi

if type fzf &> /dev/null; then
  . ${SCRIPT_DIR}/.aliases_fzf
fi

if [[ -d $HOME/enhancd ]]; then
  . $HOME/enhancd/init.sh
fi

for completion in ${SCRIPT_DIR}/completion/*; do
  . ${completion}
done
if type rustup &> /dev/null; then
  eval "$(rustup completions bash)"
  eval "$(rustup completions bash cargo)"
fi
if type gh &> /dev/null; then
  eval "$(gh completion -s bash)"
fi
if type npm &> /dev/null; then
  . <(npm completion)
fi

if type tmux &> /dev/null; then
  if [[ ${SHLVL} == 1 && ${TERM_PROGRAM} != 'vscode' ]]; then
    tmux new -A -s $(basename $(pwd) | tr -d .)
  fi
fi

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  . ${SCRIPT_DIR}/complete_alias
fi
