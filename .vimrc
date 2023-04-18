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
set visualbell t_vb=
set shellcmdflag=-ic
set runtimepath+=$HOME/.vim
set wildmode=list:longest

" show invisible chars
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

" clipboard
set clipboard&
set clipboard^=unnamedplus,unnamed

runtime! *.vimrc

" finish on vim-tiny
if !1 | finish | endif

syntax on

" highlight
hi Visual ctermbg=darkgrey ctermfg=none
hi Search ctermbg=darkyellow
hi netrwMarkFile ctermbg=darkmagenta

" cursor shape
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

" netrw
let g:netrw_liststyle=0
let g:netrw_sizestyle="H"
let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
let g:netrw_altv=1
let g:netrw_alto=1
let g:netrw_keepdir=0
"" open file in new tab
let g:netrw_browse_split=3

fun! NetrwMarkfileList(islocal)
    echo netrw#Expose("netrwmarkfilelist")
endfun
fun! NetrwGoParent(isLocal)
    return "normal -"
endfun
fun! NetrwOpen(isLocal)
    return "normal \<CR>"
endfun
fun! NetrwToggleDot(isLocal)
    return "normal gh"
endfun
fun! NetrwMark(isLocal)
    return "normal mf"
endfun
fun! NetrwUnmarkAll(isLocal)
    return "normal mF"
endfun
let g:Netrw_UserMaps= [["ml","NetrwMarkfileList"],["h","NetrwGoParent"],["l","NetrwOpen"],[".","NetrwToggleDot"],["<Tab>","NetrwMark"],["<Space><Tab>","NetrwUnmarkAll"]]
