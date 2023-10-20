#!/bin/sh

DOT_DIR="${HOME}/.dotfiles"

has() {
    type "$1" > /dev/null 2>&1
}

if has git; then
    if [ -d ${DOT_DIR} ]; then
        git -C ${DOT_DIR} pull
    else
        git clone --depth 1 https://github.com/Foo-x/dotfiles.git ${DOT_DIR}
    fi
elif has curl || has wget; then
    TARBALL="https://github.com/Foo-x/dotfiles/archive/master.tar.gz"
    if has curl; then
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
if has git && git config --global --list > /dev/null 2>&1 && ! git config --global include.path > /dev/null 2>&1; then
    git config --global include.path ${DOT_DIR}/.gitconfig
fi

# setup gh
if type gh > /dev/null 2>&1; then
    {
        gh alias set cl 'repo clone'
        gh alias set cr 'repo create'
        gh alias set il 'issue list'
        gh alias set openr 'repo view -w'
        gh alias set openi 'issue view -w'
        gh alias set openp 'pr view -w'
    } &> /dev/null
fi

# install fzf
if has git && [ ! -d ${HOME}/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
    ${HOME}/.fzf/install --key-bindings --completion --update-rc
fi

# install enhancd
if has git && [ ! -d ${HOME}/enhancd ]; then
    git clone --depth 1 https://github.com/b4b4r07/enhancd ${HOME}/enhancd
fi

# install cht.sh
mkdir -p ${HOME}/.local/bin
if [ ! -f ${HOME}/.local/bin/cht.sh ]; then
    curl https://cht.sh/:cht.sh > ${HOME}/.local/bin/cht.sh
    chmod +x ${HOME}/.local/bin/cht.sh
fi

touch ${HOME}/.user_profile

files="
.bash_profile
.gitignore_global
.gitmessage
.inputrc
.profile
.vimrc
.tmux.conf
"
echo "${files}" | xargs -I{} ln -sf ${DOT_DIR}/{} ${HOME}/{}

mkdir -p ${HOME}/.config/git/hooks
githooks_files="
prepare-commit-msg
"
echo "${githooks_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/git/hooks/{} ${HOME}/.config/git/hooks/{}

mkdir -p ${HOME}/.vim/pack/main/start/
vimrc_files="
keymap.vimrc
search.vimrc
"
echo "${vimrc_files}" | xargs -I{} ln -sf ${DOT_DIR}/.vim/{} ${HOME}/.vim/{}

# install fzf.vim
if has git && [ ! -d ${HOME}/.vim/pack/main/start/fzf.vim ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.vim.git ${HOME}/.vim/pack/main/start/fzf.vim
fi

# install vim-fugitive
if has git && [ ! -d ${HOME}/.vim/pack/main/start/vim-fugitive ]; then
    git clone --depth 1 https://github.com/tpope/vim-fugitive.git ${HOME}/.vim/pack/main/start/vim-fugitive
    vi -u NONE -c "helptags ~/.vim/pack/main/start/vim-fugitive/doc" -c q
fi

mkdir -p ${HOME}/.config/nvim
nvim_files="
init.vim
"
echo "${nvim_files}" | xargs -I{} ln -sf ${DOT_DIR}/.config/nvim/{} ${HOME}/.config/nvim/{}

exe_files="
fetch_completions.sh
fetch_git_prompt.sh
"
echo "${exe_files}" | xargs -I{} sh ${DOT_DIR}/{}

echo "Done."
