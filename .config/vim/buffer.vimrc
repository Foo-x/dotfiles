" options {{{
set switchbuf+=useopen
" }}}

" keymap {{{
nmap <Space>b <Plug>(buffer)
nnoremap <Plug>(buffer)h <C-^>
nnoremap <Plug>(buffer)l :<C-u>ls<CR>
nnoremap <Plug>(buffer)L :<C-u>ls!<CR>
nnoremap <silent> <Plug>(buffer)j :<C-u>bnext<CR>
nnoremap <silent> <Plug>(buffer)k :<C-u>bprevious<CR>
nnoremap <silent> <Plug>(buffer)x :<C-u>bdelete<CR>
" }}}

" command {{{
" skip on vim-tiny
if 1
  command! BufOnly silent! %bd|e#|bd#
  command! TQ if tabpagenr('$') > 1 | tabclose | else | qa | endif
  command! -bar WUP windo update
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

  fun! s:useopen_buffer(buf)
    let l:bnr = bufnr(a:buf)
    let l:wids = win_findbuf(bnr)
    if empty(l:wids)
      exe 'buffer' a:buf
    else
      call win_gotoid(l:wids[0])
    endif
  endf
  command! -nargs=1 -complete=buffer B silent! call s:useopen_buffer(<q-args>)

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

  fun! s:grid(bufs)
    silent! only
    exe "buffer" a:bufs[0]
    exe "vert sbuffer" a:bufs[2]
    exe "sbuffer" a:bufs[3]
    wincmd t
    exe "sbuffer" a:bufs[1]
    wincmd t
  endf
  command! Grid call s:grid(s:n_bufs(4))
  command! AGrid call s:grid(s:n_arg_bufs(4))
  fun! s:two_col(bufs)
    silent! only
    exe "buffer" a:bufs[0]
    exe "vert sbuffer" a:bufs[1]
    wincmd t
  endf
  command! TwoCol call s:two_col(s:n_bufs(2))
  command! ATwoCol call s:two_col(s:n_arg_bufs(2))
  fun! s:two_row(bufs)
    silent! only
    exe "buffer" a:bufs[0]
    exe "sbuffer" a:bufs[1]
    wincmd t
  endf
  command! TwoRow call s:two_row(s:n_bufs(2))
  command! ATwoRow call s:two_row(s:n_arg_bufs(2))

  fun! s:open_buffers_in_new_tab(is_vert, ...)
    exe 'tabnew' a:000[0]
    if len(a:000) == 1
      return
    endif

    for l:buf in a:000[1:]
      if a:is_vert
        exe 'vert sbuffer' l:buf
      else
        exe 'sbuffer' l:buf
      endif
    endfor
  endf
  command! -nargs=+ -complete=file TS silent! call s:open_buffers_in_new_tab(0, <f-args>)
  command! -nargs=+ -complete=file TV silent! call s:open_buffers_in_new_tab(1, <f-args>)
  command! -nargs=+ -complete=buffer BTS silent! call s:open_buffers_in_new_tab(0, <f-args>)
  command! -nargs=+ -complete=buffer BTV silent! call s:open_buffers_in_new_tab(1, <f-args>)
  command! -nargs=+ -complete=arglist ATS silent! call s:open_buffers_in_new_tab(0, <f-args>)
  command! -nargs=+ -complete=arglist ATV silent! call s:open_buffers_in_new_tab(1, <f-args>)
endif
" }}}
