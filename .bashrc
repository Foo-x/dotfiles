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

if type pacman &> /dev/null; then
  . ${DOT_DIR}/.config/bash/.aliases_arch
fi

if type fzf &> /dev/null; then
  . ${DOT_DIR}/.config/bash/.aliases_fzf
  . ${DOT_DIR}/.config/bash/.aliases_cdb
fi

if [[ -d $HOME/enhancd ]]; then
  . ${HOME}/enhancd/init.sh
fi

for completion in ${DOT_DIR}/completion/*; do
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
if type docker &> /dev/null; then
  . <(docker completion bash)
fi
if type mise &> /dev/null; then
  . <(mise completion bash)
fi

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
  . ${DOT_DIR}/.config/bash/complete_alias
fi

if type tmux &> /dev/null; then
  if [[ ${SHLVL} == 1 && ${TERM_PROGRAM} != 'vscode' ]]; then
    tmux attach
  fi
fi
