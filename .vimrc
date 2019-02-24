" use in your .vimrc like below
" source /path/to/dotfiles/.vimrc

syntax on
set nocompatible
set backspace=indent,eol,start
set encoding=utf-8
set cursorline
set cindent
set shiftwidth=2
set tabstop=2
set expandtab
set noerrorbells
set number
set selection=exclusive

" show invisible chars
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

" clipboard
set clipboard&
set clipboard^=unnamedplus,unnamed

" cursor shape
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

" source settings in this directory
let this_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let vimfiles = glob(this_path . '/.vimrc.*')
for vimfile in split(vimfiles, '\n')
	execute 'source ' . vimfile
endfor
