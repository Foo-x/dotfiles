cnoreabbr w!! w !sudo tee > /dev/null %
cnoreabbr FF Files
cnoreabbr FGF GFiles
cnoreabbr FB Buffers
cnoreabbr FL Lines
cnoreabbr FBL BLines
cnoreabbr FH History
cnoreabbr BND bn\|bd#
cnoreabbr BNW bn\|bw#

" finish on vim-tiny
if !1 | finish | endif

" WSL
if !empty($WSL_DISTRO_NAME)
  fun! s:inline_pbpaste()
    let l:output = system('pbpaste')
    let l:output = substitute(l:output, '\r', '', 'g')
    let l:output = substitute(l:output, '\n$', '', 'g')
    set paste
    execute 'normal i' . l:output
    set nopaste
  endf
  command! P call s:inline_pbpaste()
endif

" VSCode
fun! s:code(path, line = '', column = '')
  if !filereadable(a:path)
    echoerr 'cannot read file: ' . a:path
    return
  endif

  if !a:line && !a:column
    silent! exe '!code ' . a:path
    return
  endif

  let l:path = a:path
  if a:line
    let l:path = l:path . ':' . a:line
  endif
  if a:column
    let l:path = l:path . ':' . a:column
  endif
  silent! exe '!code --goto ' l:path
endf

"" open current file in VSCode
command! Code call s:code(expand('%:p'), line('.'), col('.'))

"" open the file under the cursor in VSCode
command! Codef call s:code(expand('<cfile>'))

fun! s:code_gF() abort
  let l:pos = matchlist(getline('.'), '\v[^[:fname:]]+([[:digit:]]+)[^[:fname:]]*([[:digit:]]*)|$', col('.'))
  call s:code(expand('<cfile>'), l:pos[1], l:pos[2])
endf
command! CodeF call s:code_gF()

" grep
command! -nargs=+ -complete=file GR execute 'silent grep! <args>' | redraw! | cw
command! -nargs=+ -complete=file LGR execute 'silent lgrep! <args>' | redraw! | lw

fun! s:git_grep(command, arg)
  let tmp1=&grepprg
  set grepprg=git\ grep\ -n\ 2>\ /dev/null
  exe a:command." ".a:arg
  let &grepprg=tmp1
endf
command! -nargs=+ -complete=file GGR silent call s:git_grep("grep", "<args>") | redraw! | cw
command! -nargs=+ -complete=file LGGR silent call s:git_grep("lgrep", "<args>") | redraw! | lw

" buffer
command! BufOnly silent! %bd|e#|bd#
fun! s:useopen_buffer(buf)
  let l:winnr = a:buf+0 == 0 ? bufwinnr(a:buf) : bufwinnr(a:buf+0)
  if l:winnr == -1
    exe 'buffer ' . a:buf
  else
    exe l:winnr . 'wincmd w'
  endif
endf
command! -nargs=1 -complete=buffer B silent! call s:useopen_buffer(<q-args>)

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

" fzf
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

