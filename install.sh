#!/bin/bash

DOT_DIR="${HOME}/.dotfiles"

has() {
    type "$1" > /dev/null 2>&1
}

if has git; then
    if [[ -d ${DOT_DIR} ]]; then
        git -C ${DOT_DIR} pull
    else
        git clone --depth 1 https://github.com/Foo-x/dotfiles.git ${DOT_DIR}
    fi
elif has curl || has wget; then
    TARBALL="https://github.com/Foo-x/dotfiles/archive/master.tar.gz"
    if has "curl"; then
        curl -L ${TARBALL} -o master.tar.gz
    else
        wget ${TARBALL}
    fi
    tar -zxvf master.tar.gz
    rm -f master.tar.gz
    mv -f dotfiles-master ${DOT_DIR}
else
    echo "curl or wget or git required"
    exit 1
fi

# include .bashrc
touch ${HOME}/.bashrc
source_bashrc=". ${DOT_DIR}/.bashrc"
if ! \grep -q "${source_bashrc}" ${HOME}/.bashrc; then
    echo "${source_bashrc}" >> ${HOME}/.bashrc
fi

# include .gitconfig
touch ${HOME}/.gitconfig
if has git && ! git config --global include.path &> /dev/null; then
    git config --global include.path ${DOT_DIR}/.gitconfig
fi

# include alacritty.yml
is_docker=$([[ -f /.dockerenv ]] || \grep -Eq '(lxc|docker)' /proc/1/cgroup; echo $?)
if [[ ${is_docker} != 0 ]] && [[ $(uname -a) =~ Microsoft|microsoft ]]; then
    alacritty_config=$(wslpath "$(wslvar APPDATA)")/alacritty/alacritty.yml
    dotdir_alacritty_config=$(wslpath -m ${DOT_DIR}/alacritty.yml)
else
    alacritty_config=${HOME}/.alacritty.yml
    dotdir_alacritty_config=${DOT_DIR}/alacritty.yml
fi
touch ${alacritty_config}
source_alacritty_config="import: [\"${dotdir_alacritty_config}\"]"
if ! \grep -Fq "${source_alacritty_config}" ${alacritty_config}; then
    echo "${source_alacritty_config}" >> ${alacritty_config}
fi

touch ${HOME}/.user_profile

files="
.bash_profile
.gfc.json
.inputrc
.profile
.vimrc
.tmux.conf
"
echo "${files}" | xargs -I{} ln -sf ${DOT_DIR}/{} ${HOME}/{}

mkdir -p ${HOME}/.vim
vimrc_files="
keymap.vimrc
search.vimrc
"
echo "${vimrc_files}" | xargs -I{} ln -sf ${DOT_DIR}/.vim/{} ${HOME}/.vim/{}

exe_files="
complete_docker_compose.sh
fetch_git_completions.sh
"
echo "${exe_files}" | xargs -I{} bash ${DOT_DIR}/{}

if has git && [[ ! -d ${HOME}/.fzf ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
    ${HOME}/.fzf/install --key-bindings --completion --update-rc
fi

echo "Done."
