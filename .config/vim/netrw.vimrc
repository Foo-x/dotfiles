" finish on vim-tiny
if !1 | finish | endif

let g:netrw_home = $XDG_DATA_HOME."/vim"

let g:netrw_liststyle=0
let g:netrw_sizestyle="H"
let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
let g:netrw_altv=1
let g:netrw_alto=1
let g:netrw_keepdir=0
let g:netrw_localcopydircmd='cp -r'
let g:netrw_browsex_viewer='open'

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
