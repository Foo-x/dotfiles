" options {{{
set grepformat^=%f:%l:%c:%m
set grepprg=git\ grep\ --no-index\ --exclude-standard\ --no-color\ -n\ --column\ -I\ -P
if executable('rg')
  set grepprg=rg\ --vimgrep\ --sort=path
endif
" }}}

" keymap {{{
cnoreabbr <expr> gr getcmdtype() == ':' && getcmdline() ==# 'gr' ? 'silent grep!' : 'gr'
cnoreabbr <expr> grep getcmdtype() == ':' && getcmdline() ==# 'grep' ? 'silent grep!' : 'grep'
cnoreabbr <expr> rg getcmdtype() == ':' && getcmdline() ==# 'rg' ? 'Rg' : 'rg'
" }}}
