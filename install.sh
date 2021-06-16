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

# include .profile
touch ${HOME}/.profile
source_profile=". ${DOT_DIR}/.profile"
if ! \grep -q "${source_profile}" ${HOME}/.profile; then
    echo "${source_profile}" >> ${HOME}/.profile
fi

# include .gitconfig
touch ${HOME}/.gitconfig
if has git && ! git config --global include.path &> /dev/null; then
    git config --global include.path ${DOT_DIR}/.gitconfig
fi

files="
.inputrc
.vimrc
.vimrc.keymap
.vimrc.search
"
echo "${files}" | xargs -I{} ln -sf ${DOT_DIR}/{} ${HOME}/{}

exe_files="
complete_docker_compose.sh
fetch_git_completions.sh
"
echo "${exe_files}" | xargs -I{} bash ${DOT_DIR}/{}

if has git && [[ ! -d ${HOME}/.fzf ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
    ${HOME}/.fzf/install --no-key-bindings --no-completion --update-rc
fi

echo "Done."
