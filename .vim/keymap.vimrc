" normal mode
"" display lines downward
nnoremap j gj
nnoremap <Down> gj

"" display lines upward
nnoremap k gk
nnoremap <Up> gk

noremap Y y$
nnoremap <C-j> i<CR><Esc>

nnoremap + <C-a>
nnoremap - <C-x>

"" not to go next
nnoremap * *N

"" go to parent braces/brackets/parentheses
nnoremap [[ "_ya[
nnoremap [{ "_ya{
nnoremap [( "_ya(
nnoremap [] "_ya[
nnoremap [} "_ya{
nnoremap [) "_ya(
nnoremap ][ "_ya[%
nnoremap ]{ "_ya{%
nnoremap ]( "_ya(%
nnoremap ]] "_ya[%
nnoremap ]} "_ya{%
nnoremap ]) "_ya(%

noremap <Space>h ^
nnoremap <Space>l $
vnoremap <Space>l $h
noremap <Space>m %
nnoremap <Space>/ *

nnoremap <Space>o o<Esc>
nnoremap <Space>O O<Esc>

nnoremap <Space>j <C-f>
nnoremap <Space>k <C-b>

nnoremap <Space><Space>t :<C-u>tab ter<CR>

"" insert only one character
nnoremap <Space>i i_<Esc>r

nmap <Space>b [buffer]
nnoremap [buffer]l :<C-u>ls<CR>
nnoremap [buffer]L :<C-u>ls!<CR>
nnoremap <silent> [buffer]j :<C-u>bnext<CR>
nnoremap <silent> [buffer]k :<C-u>bprevious<CR>
nnoremap <silent> [buffer]x :<C-u>bdelete<CR>

nmap <Space><Space>c [quickfix]
nnoremap [quickfix]n :<C-u>cnext<CR>
nnoremap [quickfix]p :<C-u>cprevious<CR>
nnoremap [quickfix]k :<C-u>cbefore<CR>
nnoremap [quickfix]j :<C-u>cafter<CR>
nnoremap [quickfix]w :<C-u>cwindow<CR>
nnoremap [quickfix]c :<C-u>cclose<CR>

nmap <Space><Space>l [location]
nnoremap [location]n :<C-u>lnext<CR>
nnoremap [location]p :<C-u>lprevious<CR>
nnoremap [location]k :<C-u>lbefore<CR>
nnoremap [location]j :<C-u>lafter<CR>
nnoremap [location]w :<C-u>lwindow<CR>
nnoremap [location]c :<C-u>lclose<CR>

nmap <Space>w [window]
nnoremap <silent> [window]_ :<C-u>split<CR>
nnoremap <silent> [window]\ :<C-u>vsplit<CR>
nnoremap [window]c <C-w>c
nnoremap [window]h <C-w>h
nnoremap [window]j <C-w>j
nnoremap [window]k <C-w>k
nnoremap [window]l <C-w>l
nnoremap [window]H <C-w>H
nnoremap [window]J <C-w>J
nnoremap [window]K <C-w>K
nnoremap [window]L <C-w>L
nnoremap [window]m <C-w>\|<C-w>_
nnoremap [window]= <C-w>=
nnoremap [window]> <C-w>>
nnoremap [window]< <C-w><
nnoremap [window]+ <C-w>+
nnoremap [window]- <C-w>-

nmap <Space>t [tab]
nnoremap <silent> [tab]t :<C-u>tabnew<CR>
nnoremap [tab]h gT
nnoremap [tab]j gT
nnoremap [tab]k gt
nnoremap [tab]l gt

"" not to yunk
nnoremap x "_x
nnoremap X "_X
nnoremap s "_s
nnoremap S "_S

"" format all lines
nnoremap <Space>= gg=G

"" yank all lines
nnoremap <Space>y ggyG

"" select all
nnoremap <Space>v ggVG

"" delete all
nnoremap <Space>d ggdG

"" move to end after pasting
nnoremap <silent> p p`]

nnoremap <Space>s :%s/

"" disable highlight
nnoremap <C-l> :nohlsearch<CR><C-l>

"" correct quit
nnoremap q: :q

" insert mode
inoremap jj    <Esc>

" visual mode
vnoremap + <C-a>gv
vnoremap - <C-x>gv
vnoremap g+ g<C-a>gv
vnoremap g- g<C-x>gv

"" not to override register on paste
vnoremap p pgvy

"" highlight selected
vnoremap <silent> * "zy/<C-r>z<CR>N

"" continue visual mode after indenting
vnoremap > >gv
vnoremap < <gv

"" move to end after yank
vnoremap <silent> y y`]

vnoremap <Space>s( di()<Esc>P
vnoremap <Space>s{ di{}<Esc>P
vnoremap <Space>s[ di[]<Esc>P
vnoremap <Space>s< di<><Esc>P
vnoremap <Space>s" di""<Esc>P
vnoremap <Space>s' di''<Esc>P

" command mode
cnoreabbr w!! w !sudo tee > /dev/null %
cnoreabbr FF Files
cnoreabbr FGF GFiles
cnoreabbr FB Buffers
cnoreabbr FL Lines
cnoreabbr FBL BLines
cnoreabbr FH History
command! -nargs=+ -complete=file GR execute 'silent grep! <args>' | redraw! | cw
command! -nargs=+ -complete=file LGR execute 'silent lgrep! <args>' | redraw! | lw

" terminal mode
tnoremap <C-n> <C-w>N
tnoremap <silent><C-w><C-d> <C-w>N:<C-u>bd!<CR>:<C-u>q<CR>

" finish on vim-tiny
if !1 | finish | endif

" comand mode
fun! s:git_grep(command, arg)
  let tmp1=&grepprg
  set grepprg=git\ grep\ -n\ 2>\ /dev/null
  exe a:command." ".a:arg
  let &grepprg=tmp1
endf
command! -nargs=+ -complete=file GGR silent call s:git_grep("grep", "<args>") | redraw! | cw
command! -nargs=+ -complete=file LGGR silent call s:git_grep("lgrep", "<args>") | redraw! | lw
command! BufOnly silent! %bd|e#|bd#

fun! s:badd_multi(...)
  for file in a:000
    exe "badd " . file
  endfor
endf
command! -nargs=+ -complete=file BaddMulti call s:badd_multi(<f-args>)

fun! s:n_bufs(n)
  if a:n < 1
    return []
  endif

  if a:n == 1
    return [winbufnr(1)]
  endif

  let s:inactive_bufs = []

  for bufnum in range(1, bufnr('$'))
    if buflisted(bufnum) && bufwinnr(bufnum) == -1
      call add(s:inactive_bufs, bufnum)
    endif
  endfor

  let s:wins = []
  let s:bufs = []

  1wincmd w
  call add(s:bufs, bufnr())
  call add(s:wins, winnr())

  for i in range(2, a:n)
    silent! exe i . "wincmd w"
    let s:tmp_win = winnr()
    if index(s:wins, s:tmp_win) >= 0 && s:inactive_bufs->len() > 0
      call add(s:bufs, remove(s:inactive_bufs, 0))
    elseif index(s:wins, s:tmp_win) >= 0
      1wincmd w
      exe i . "bnext"
      call add(s:bufs, bufnr())
      exe i . "bprevious"
    else
      call add(s:bufs, winbufnr(s:tmp_win))
    endif
    call add(s:wins, s:tmp_win)
  endfor

  return s:bufs
endf

fun! s:grid()
  let s:bufs = s:n_bufs(4)

  silent! only
  exe "buffer " . s:bufs[0]
  exe "vert sbuffer " . s:bufs[2]
  exe "sbuffer " . s:bufs[3]
  wincmd t
  exe "sbuffer " . s:bufs[1]
  wincmd t
endf
command! Grid call s:grid()

fun! s:two_col()
  let s:bufs = s:n_bufs(2)

  silent! only
  exe "buffer " . s:bufs[0]
  exe "vert sbuffer " . s:bufs[1]
  wincmd t
endf
command! TwoCol call s:two_col()

fun! s:list_buffers(unlisted = '')
  redir => list
  silent exe 'ls' . a:unlisted
  redir END
  return split(list, "\n")
endf

fun! s:delete_buffers(command, lines)
  execute a:command join(map(a:lines, {_, line -> split(split(line)[0],'[^0-9]\+')[0]}))
endf

command! FBD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers('bdelete', lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
\ }))

command! FBW call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers('!'),
  \ 'sink*': { lines -> s:delete_buffers('bwipeout', lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
\ }))
