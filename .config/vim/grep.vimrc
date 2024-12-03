" options {{{
set grepformat^=%f:%l:%c:%m
set grepprg=git\ grep\ --no-index\ --exclude-standard\ --no-color\ -n\ --column\ -I\ -P
if executable('rg')
  " `rg | sort` is faster than `rg --sort`
  let &grepprg='rg --vimgrep $* \| sort'
endif
" }}}

" keymap {{{
nnoremap <Space>r <Plug>(grep)
nnoremap <Plug>(grep)<CR> :<C-u>silent grep!<Space>
nnoremap <Plug>(grep). :<C-u>silent grep! '<C-r>=expand('<cword>')<CR>'<Space>

vnoremap <Space>r <Plug>(grep)
vnoremap <Plug>(grep). <Esc>:<C-u>silent grep! -U "<C-r>=substitute(escape(join(getregion(getpos("'<"), getpos("'>")), '\n'), '"\\.+*?\|^$()[]{}#'), '\\n', 'n', 'g')<CR>"<Space>
" }}}

"command {{{
cnoreabbr <expr> gr getcmdtype() == ':' && getcmdline() ==# 'gr' ? 'silent grep!' : 'gr'
cnoreabbr <expr> grep getcmdtype() == ':' && getcmdline() ==# 'grep' ? 'silent grep!' : 'grep'

fun! s:grep_cursor()
  if mode() == 'v'
    let l:selected = join(getregion(getpos("'<"), getpos("'>")), '')
  endif
endf
" }}}
