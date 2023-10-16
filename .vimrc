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
set runtimepath+=$HOME/.vim
set noswapfile
set wildmenu
set wildmode=list:longest
set laststatus=2
set statusline=%F%m%r%h%w%=%l,%v/%L\ %{&ff}\ %{&fenc!=''?&fenc:&enc}\ %y
set isk+=-
set formatoptions+=M
set matchpairs+=<:>
set scrolloff=5
set shortmess+=FI
set shortmess-=S

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
hi Comment ctermfg=lightblue
hi Directory ctermfg=lightblue
hi Identifier ctermfg=lightblue
hi NonText ctermfg=lightblue
hi PreProc ctermfg=red
hi Question ctermfg=lightgreen
hi Search ctermbg=darkyellow ctermfg=white
hi Statement ctermfg=yellow
hi Visual ctermbg=darkgrey ctermfg=none
hi netrwMarkFile ctermbg=darkmagenta ctermfg=white

" cursor shape
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

" load bash alias
let $BASH_ENV="$HOME/.dotfiles/.aliases"

" netrw
let g:netrw_liststyle=0
let g:netrw_sizestyle="H"
let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
let g:netrw_altv=1
let g:netrw_alto=1
let g:netrw_keepdir=0
let g:netrw_localcopydircmd='cp -r'
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
fun! g:MyNetrw_D(islocal)
    " get selected file list (:h netrw-mf)
    let l:flist = netrw#Expose('netrwmarkfilelist')
    if l:flist is# 'n/a'
        " no selection -- get name under cursor
        let l:flist = [b:netrw_curdir . '/' . netrw#GX()]
    else
        " remove selection as files will be deleted soon
        call netrw#Call('NetrwUnmarkAll')
    endif
    " do delete and refresh view
    echo system('rm -rf ' . join(l:flist))
    return 'refresh'
endfun
let g:Netrw_UserMaps= [["ml","NetrwMarkfileList"],["h","NetrwGoParent"],["l","NetrwOpen"],[".","NetrwToggleDot"],["<Tab>","NetrwMark"],["<Space><Tab>","NetrwUnmarkAll"],["D", "MyNetrw_D"]]
