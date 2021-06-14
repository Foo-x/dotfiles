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

umask 022

. ${SCRIPT_DIR}/.aliases
. ${SCRIPT_DIR}/.aliases_arch
. ${SCRIPT_DIR}/.aliases_fzf
. ${SCRIPT_DIR}/.exports
. ${SCRIPT_DIR}/.git-completion
. ${SCRIPT_DIR}/complete_alias
