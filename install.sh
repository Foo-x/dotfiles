#!/usr/bin/env sh

export DOT_DIR="${HOME}/.dotfiles"
XDG_CONFIG_HOME="${HOME}/.config"
XDG_CACHE_HOME="${HOME}/.cache"
XDG_DATA_HOME="${HOME}/.local/share"
XDG_STATE_HOME="${HOME}/.local/state"

has() {
  type "$1" > /dev/null 2>&1
}

if [ ! ${IS_UPDATED} ]; then
  if ! has git; then
    echo "git required" 1>&2
    exit 1
  fi

  if [ -d ${DOT_DIR} ]; then
    git -C ${DOT_DIR} pull
  else
    git clone --depth 1 https://github.com/Foo-x/dotfiles.git ${DOT_DIR}
  fi

  export IS_UPDATED=true
  ${DOT_DIR}/install.sh
  exit 0
fi

mkdir -p ${XDG_CONFIG_HOME}
mkdir -p ${XDG_CACHE_HOME}
mkdir -p ${XDG_DATA_HOME}
mkdir -p ${XDG_STATE_HOME}

# install fzf
if [ ! -d ${HOME}/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
  ${HOME}/.fzf/install --key-bindings --completion --update-rc
fi
# install fzf-tab-completion
if [ ! -d ${HOME}/.fzf-tab-completion ]; then
  git clone --depth 1 https://github.com/lincheney/fzf-tab-completion.git ${HOME}/.fzf-tab-completion
fi
# include .bashrc
touch ${HOME}/.bashrc
source_bashrc=". ${DOT_DIR}/.bashrc"
sed -ie "\~${source_bashrc}~d" ${HOME}/.bashrc
if \grep -qF "fzf" ${HOME}/.bashrc; then
  # load bashrc before fzf because LS_COLORS must be set before loading inputrc and fzf use 'bind' which loads inputrc
  sed -ie "/fzf/i ${source_bashrc}" ${HOME}/.bashrc
else
  echo "${source_bashrc}" >> ${HOME}/.bashrc
fi

mkdir -p ${HOME}/.local/bin
binfiles="
bfs
f
jj_desc_template
nvimdirdiff
vipe
win_git
"
echo "${binfiles}" | xargs -I{} ln -sfT ${DOT_DIR}/bin/{} ${HOME}/.local/bin/{}
export PATH="${HOME}/.local/bin:${PATH}"

touch ${HOME}/.user_profile

dotfiles="
.bash_profile
.inputrc
.profile
"
echo "${dotfiles}" | xargs -I{} ln -sf ${DOT_DIR}/{} ${HOME}/{}

# setup git
git config --global include.path ${DOT_DIR}/.config/git/config

mkdir -p ${XDG_CONFIG_HOME}/git
gitconfig_files="
ignore
"
echo "${gitconfig_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/git/{} ${XDG_CONFIG_HOME}/git/{}
[ -f ${HOME}/.gitconfig ] && mv ${HOME}/.gitconfig ${XDG_CONFIG_HOME}/git/config
sh ${DOT_DIR}/.config/git/config_dynamic

# setup jj
JJ_DIR=${XDG_CONFIG_HOME}/jj
mkdir -p ${JJ_DIR}
ln -sf ${DOT_DIR}/.config/jj/config.toml ${JJ_DIR}/config.toml
JJ_CONF_DIR=${JJ_DIR}/conf.d
mkdir -p ${JJ_CONF_DIR}
touch ${JJ_CONF_DIR}/user.toml

# setup tmux
TMUX_DIR=${XDG_CONFIG_HOME}/tmux
mkdir -p ${TMUX_DIR}
ln -sf ${DOT_DIR}/.config/tmux/tmux.conf ${TMUX_DIR}/tmux.conf

# install tmux-resurrect
if [ ! -d ${TMUX_DIR}/tmux-resurrect ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tmux-resurrect.git ${TMUX_DIR}/tmux-resurrect
fi

# install tmux-continuum
if [ ! -d ${TMUX_DIR}/tmux-continuum ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tmux-continuum.git ${TMUX_DIR}/tmux-continuum
fi

# install nix
if ! has nix; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  cd "${DOT_DIR}"
  nix run .#switch-home
  cd -
fi

# install devbox
if ! has devbox; then
  curl -fsSL https://get.jetify.com/devbox | bash
fi

# install hotspots
if ! has hotspots; then
  curl -fsSL https://raw.githubusercontent.com/Foo-x/hotspots/refs/heads/master/hotspots -o ${HOME}/.local/bin/hotspots
fi

# setup ripgrep
mkdir -p "${XDG_CONFIG_HOME}/ripgrep"
ln -sf "${DOT_DIR}/.config/ripgrep/ripgreprc" "${XDG_CONFIG_HOME}/ripgrep/ripgreprc"

if has gh; then
  {
    gh alias set --clobber cl 'repo clone'
    gh alias set --clobber clp 'repo clone $1 -- --filter=blob:none'
    gh alias set --clobber clps 'repo clone $1 -- --filter=blob:none --sparse'
    gh alias set --clobber cr 'repo create'
    gh alias set --clobber il 'issue list'
    gh alias set --clobber co 'pr checkout'
    gh alias set --clobber al 'alias list'
    gh alias set --clobber openr 'repo view -w'
    gh alias set --clobber openi 'issue view -w'
    gh alias set --clobber openp 'pr view -w'
    gh alias set --clobber --shell sync 'gh repo sync $(git config --get remote.origin.url | \grep -oP "(?<=/)[^/.]+?/[^.]+")'
  } > /dev/null 2>&1
fi

# install yargs
if ! bun pm ls -g | grep -q yargs; then
  bun install -g yargs
fi
# install wsl-open
IS_WSL="$(if uname -r | \grep -iq 'microsoft'; then echo 1; else echo 0; fi)"
if [ ${IS_WSL} = 1 ] && ! has wsl-open; then
  bun install -g wsl-open
fi

exe_files="
setup_completions.sh
"
echo "${exe_files}" | xargs -I{} sh ${DOT_DIR}/{}

# install alacritty theme
if [ ! -d ${HOME}/.alacritty-theme ]; then
  git clone --depth 1 https://github.com/alacritty/alacritty-theme ${HOME}/.alacritty-theme
fi

# setup aichat
mkdir -p ${XDG_CONFIG_HOME}/aichat
ln -sf ${DOT_DIR}/aichat/roles ${XDG_CONFIG_HOME}/aichat

# setup spzenhan
if uname -r | \grep -iq 'microsoft'; then
  if [ ! -x ${HOME}/.local/bin/spzenhan.exe ]; then
    curl -Lo ${HOME}/.local/bin/spzenhan.exe https://github.com/kaz399/spzenhan.vim/raw/master/zenhan/spzenhan.exe
    chmod +x ${HOME}/.local/bin/spzenhan.exe
  fi
fi

# setup bash history
mkdir -p ${XDG_STATE_HOME}/bash
if [ -f ${HOME}/.bash_history ]; then
  cat ${HOME}/.bash_history >> ${XDG_STATE_HOME}/bash/history
  rm ${HOME}/.bash_history
fi

# setup kanbanmd
if [ ! -d ${XDG_DATA_HOME}/kanbanmd ]; then
  cp -r ${DOT_DIR}/kanbanmd ${XDG_DATA_HOME}
else
  \cp ${DOT_DIR}/kanbanmd/README.md ${XDG_DATA_HOME}/kanbanmd
fi

# setup vim
mkdir -p ${XDG_CONFIG_HOME}/vim
vimrc_files=$(cd ${DOT_DIR}/.config/vim && \ls -1)
printf "${vimrc_files}" | xargs -I{} ln -sfT ${DOT_DIR}/.config/vim/{} ${XDG_CONFIG_HOME}/vim/{}

# setup nvim
mkdir -p ${XDG_CONFIG_HOME}/nvim
nvim_files=$(cd ${DOT_DIR}/.config/nvim && \ls -1)
printf "${nvim_files}" | xargs -I{} ln -sfT ${DOT_DIR}/.config/nvim/{} ${XDG_CONFIG_HOME}/nvim/{}

# setup vsnip
ln -sfn ${DOT_DIR}/snippets ${HOME}/.vsnip

# setup ctags
mkdir -p ${XDG_CONFIG_HOME}/ctags
ctags_files=$(cd ${DOT_DIR}/.config/ctags && \ls -1)
printf "${ctags_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/ctags/{} ${XDG_CONFIG_HOME}/ctags/{}

# setup gitui
ln -sf ${DOT_DIR}/.config/gitui ${XDG_CONFIG_HOME}

# setup mcphub
ln -sf ${DOT_DIR}/.config/mcphub ${XDG_CONFIG_HOME}

# setup aider
ln -sf "${DOT_DIR}/aider/.aider.conf.yml" "${HOME}/.aider.conf.yml"

echo "Done."
