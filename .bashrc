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

for completion in ${DOT_DIR}/completion/*; do
  . ${completion}
done
complete -C terraform terraform
complete -C terraform tf

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
  . ${DOT_DIR}/.config/bash/complete_alias
fi

if [ -d ${HOME}/.fzf-tab-completion ]; then
  . ${HOME}/.fzf-tab-completion/bash/fzf-bash-completion.sh
  # bind S-tab to fzf bash completion
  bind -x '"\e[Z": fzf_bash_completion'
fi

if type tmux &> /dev/null; then
  if [[ -z ${TMUX} && ${TERM_PROGRAM} != 'vscode' ]]; then
    if [[ ${IS_WSL} == 1 ]] && ! \grep -iq 'appendWindowsPath *= *false' /etc/wsl.conf; then
      while ! [[ "$PATH" =~ '/mnt/c/windows/system32' ]]; do sleep 0.2; done
    fi
    while ! tmux attach &> /dev/null; do sleep 0.2; done
  fi
fi
