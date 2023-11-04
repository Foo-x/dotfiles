cnoreabbr w!! w !sudo tee > /dev/null %
cnoreabbr BND bn\|bd#
cnoreabbr BNW bn\|bw#

" argument list
cnoreabbr A args
cnoreabbr AD argdelete
cnoreabbr ADA %argdelete
cnoreabbr ADD argdedupe

" fzf
cnoreabbr FF Files
cnoreabbr FGF GFiles
cnoreabbr FB Buffers
cnoreabbr FL Lines
cnoreabbr FBL BLines
cnoreabbr FH History

" vim-fugitive
cnoreabbr GDT G difftool -y
cnoreabbr GMT G mergetool -y \| .,$tabdo on \| Gvdiffsplit! \| winc J \| winc t \| Gvdiffsplit :1 \| winc j

" gv.vim
cnoreabbr GV0a GV --all
cnoreabbr GV1 GV --name-status
cnoreabbr GV1a GV --name-status --all

" finish on vim-tiny
if !1 | finish | endif

" WSL
if !empty($WSL_DISTRO_NAME)
  fun! InlinePbpaste(r = 0)
    let l:output = system('pbpaste')
    let l:output = substitute(l:output, '\r', '', 'g')
    let l:output = substitute(l:output, '\n$', '', 'g')
    call setreg('', l:output)

    if a:r > 0
      norm gvp
    else
      norm p
    endif
  endf
  command! -range P call InlinePbpaste(<range>)
  vnoremap <silent> P :call InlinePbpaste(1)<CR>
endif

" VSCode
fun! s:code(path, line = '', column = '')
  if !filereadable(expand(a:path))
    echoerr 'cannot read file: ' . a:path
    return
  endif

  if !a:line && !a:column
    silent! exe '!code ' . a:path
    redraw!
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
  redraw!
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
command! -nargs=+ -complete=file -bang GGR silent call s:git_grep("grep<bang>", <q-args>) | redraw! | cw
command! -nargs=+ -complete=file -bang LGGR silent call s:git_grep("lgrep<bang>", <q-args>) | redraw! | lw
command! -bang Conflicts GGR<bang> '^<<<<<<< HEAD$'

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
command! -nargs=+ -complete=file AA argadd <args> | argdedupe

fun! s:close_no_name_buffers()
  let l:nonamebuffers = map(filter(getbufinfo({'buflisted':1}), 'v:val.name=="" && len(v:val.windows)==0'), 'v:val.bufnr')
  for i in l:nonamebuffers
    exe 'bdelete ' . i
  endfor
endf
command! CloseNoNameBuffers call s:close_no_name_buffers()

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
fun! s:two_row()
  let s:bufs = s:n_bufs(2)

  silent! only
  exe "buffer " . s:bufs[0]
  exe "sbuffer " . s:bufs[1]
  wincmd t
endf
command! TwoRow call s:two_row()

" fzf
fun! s:list_buffers(unlisted = '')
  redir => list
  silent exe 'ls' . a:unlisted
  redir END
  return split(list, "\n")
endf

fun! s:delete_buffers(command, lines)
  let l:bufnrs = map(a:lines, {_, line -> split(split(line)[0],'[^0-9]\+')[0]})
  let l:bufnames = map(copy(l:bufnrs), {_, val -> bufname(str2nr(val))})
  silent! execute 'argdelete' join(l:bufnames)
  execute a:command join(l:bufnrs)
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

