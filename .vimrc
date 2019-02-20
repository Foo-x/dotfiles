" use in your .vimrc like below
" source /path/to/dotfiles/.vimrc

syntax on
set nocompatible
set backspace=indent,eol,start
set encoding=utf-8
set cursorline
set smartindent
set shiftwidth=2
set tabstop=2
set noerrorbells
set number
set selection=exclusive

" show invisible chars
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

" clipboard
set clipboard&
set clipboard^=unnamedplus,unnamed

" source settings in this directory
let this_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let vimfiles = glob(this_path . '/.vimrc.*')
for vimfile in split(vimfiles, '\n')
	execute 'source ' . vimfile
endfor
