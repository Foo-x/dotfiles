" options {{{
set switchbuf+=useopen
" }}}

" keymap {{{
nmap <Space>b <Plug>(buffer)
nnoremap <Plug>(buffer)h <C-^>
nnoremap <Plug>(buffer)l :<C-u>ls<CR>
nnoremap <Plug>(buffer)L :<C-u>ls!<CR>
nnoremap <Plug>(buffer)g :<C-u>Grid<CR>
nnoremap <Plug>(buffer)ag :<C-u>AGrid<CR>
nnoremap <Plug>(buffer)c :<C-u>TwoCol<CR>
nnoremap <Plug>(buffer)ac :<C-u>ATwoCol<CR>
nnoremap <Plug>(buffer)r :<C-u>TwoRow<CR>
nnoremap <Plug>(buffer)ar :<C-u>ATwoRow<CR>
" }}}

" command {{{
command! BufOnly silent! %bd|e#|bd#
command! TQ if tabpagenr('$') > 1 | tabclose | else | qa | endif
command! -bar WUP windo update
command! ScratchTab tabnew | set buftype=nofile
cnoreabbr WQ WUP \| TQ

fun! DeleteBuffers(command, bufnrs)
  let l:bufnames = map(copy(a:bufnrs), {_, val -> bufname(str2nr(val))})
  silent! execute 'argdelete' join(l:bufnames)
  execute a:command join(a:bufnrs)
endf

fun! s:bclose(command)
  let l:alt_bufinfo = getbufinfo('#')
  if l:alt_bufinfo[0].listed
    b#
  else
    bp
  endif
  call DeleteBuffers(a:command, ['#'])
endf
command! BD call s:bclose('bd')
command! BW call s:bclose('bw')

fun! s:clean_nonexistent_buffers()
  let l:nonexistent_buffers = map(filter(getbufinfo({'buflisted':1}), '!filereadable(expand(v:val.name))'), 'v:val.bufnr')
  call DeleteBuffers('bwipeout', l:nonexistent_buffers)
endf
command! CleanNonExistentBuffers call s:clean_nonexistent_buffers()

fun! s:close_no_name_buffers()
  let l:nonamebuffers = map(filter(getbufinfo({'buflisted':1}), 'v:val.name=="" && len(v:val.windows)==0'), 'v:val.bufnr')
  for i in l:nonamebuffers
    exe 'bdelete' i
  endfor
endf
command! CloseNoNameBuffers call s:close_no_name_buffers()

fun! s:n_bufs(n)
  if a:n < 1
    return []
  endif

  let l:bufinfo = filter(getbufinfo(), 'v:val.listed')
  let l:all_bufs = map(copy(l:bufinfo), 'v:val.bufnr')
  let l:wininfo = filter(getwininfo(), 'v:val.winnr <= a:n && v:val.tabnr == tabpagenr() && index(l:all_bufs, v:val.bufnr) >= 0')
  let l:winnrs = map(copy(l:wininfo), 'v:val.winnr')
  let l:winbufs = map(copy(l:wininfo), 'v:val.bufnr')
  let l:inactive_bufs = filter(copy(l:all_bufs), 'bufwinnr(v:val) == -1')

  let l:bufs = []
  for l:i in range(1, a:n)
    let l:winbuf_idx = index(l:winnrs, l:i)
    if l:winbuf_idx >= 0
      call add(l:bufs, l:winbufs->get(l:winbuf_idx))
      continue
    endif
    if l:inactive_bufs->len() > 0
      call add(l:bufs, remove(l:inactive_bufs, 0))
      continue
    endif
    let l:idx = (l:i - 1) % l:all_bufs->len()
    call add(l:bufs, l:all_bufs->get(l:idx))
  endfor

  return l:bufs
endf

fun! s:n_arg_bufs(n)
  if a:n < 1
    return []
  endif

  let l:argv = argv()
  if l:argv->len() == 0
    return []
  endif

  let l:arg_bufs = map(l:argv, 'bufnr(v:val)')
  let l:wininfo = filter(getwininfo(), 'v:val.winnr <= a:n && v:val.tabnr == tabpagenr() && index(l:argv, bufname(v:val.bufnr)) >= 0')
  let l:winnrs = map(copy(l:wininfo), 'v:val.winnr')
  let l:winbufs = map(copy(l:wininfo), 'v:val.bufnr')
  let l:inactive_arg_bufs = filter(map(argv(), 'bufnr(v:val)'), 'index(l:winbufs, v:val) == -1')

  let l:bufs = []
  for l:i in range(1, a:n)
    let l:winbuf_idx = index(l:winnrs, l:i)
    if l:winbuf_idx >= 0
      call add(l:bufs, l:winbufs->get(l:winbuf_idx))
      continue
    endif
    if l:inactive_arg_bufs->len() > 0
      call add(l:bufs, remove(l:inactive_arg_bufs, 0))
      continue
    endif
    let l:idx = (l:i - 1) % l:arg_bufs->len()
    call add(l:bufs, l:arg_bufs->get(l:idx))
  endfor

  return l:bufs
endf

fun! s:fill_win(setup, bufs)
  silent! only
  call a:setup()

  let l:i = 0
  while l:i < len(a:bufs)
    exe (l:i + 1) . 'winc w'
    exe 'buffer' a:bufs[l:i]
    let l:i += 1
  endwhile

  winc t
endf
command! Grid call s:fill_win({ -> execute('split | windo vsplit') }, s:n_bufs(4))
command! AGrid call s:fill_win({ -> execute('split | windo vsplit') }, s:n_arg_bufs(4))
command! TwoCol call s:fill_win({ -> execute('vsplit') }, s:n_bufs(2))
command! ATwoCol call  s:fill_win({ -> execute('vsplit') }, s:n_arg_bufs(2))
command! TwoRow call s:fill_win({ -> execute('split') }, s:n_bufs(2))
command! ATwoRow call  s:fill_win({ -> execute('split') }, s:n_arg_bufs(2))

fun! s:update_oldfiles(file)
  if !exists('v:oldfiles')
    return
  endif
  let l:idx = index(v:oldfiles, a:file)
  if l:idx != -1
    call remove(v:oldfiles, l:idx)
  endif
  if len(a:file) != 0
    call insert(v:oldfiles, a:file, 0)
  endif
endf
augroup UpdateOldfiles
  autocmd!
  autocmd BufEnter * call s:update_oldfiles(expand('<afile>:p'))
augroup END
" }}}
