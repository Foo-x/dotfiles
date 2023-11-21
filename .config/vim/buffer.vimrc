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

    if a:n == 1
      return [winbufnr(1)]
    endif

    let l:inactive_bufs = []

    for l:bufnum in range(1, bufnr('$'))
      if buflisted(l:bufnum) && bufwinnr(l:bufnum) == -1
        call add(l:inactive_bufs, l:bufnum)
      endif
    endfor

    let l:bufs = []
    let l:wins = []

    1wincmd w
    call add(l:bufs, bufnr())
    call add(l:wins, winnr())

    for l:i in range(2, a:n)
      silent! exe l:i . "wincmd w"
      let l:tmp_win = winnr()
      if index(l:wins, l:tmp_win) >= 0 && l:inactive_bufs->len() > 0
        call add(l:bufs, remove(l:inactive_bufs, 0))
      elseif index(l:wins, l:tmp_win) >= 0 || !getbufinfo(winbufnr(l:tmp_win))[0].listed
        1wincmd w
        exe l:i . "bnext"
        call add(l:bufs, bufnr())
        exe l:i . "bprevious"
      else
        call add(l:bufs, winbufnr(l:tmp_win))
      endif
      call add(l:wins, l:tmp_win)
    endfor

    return l:bufs
  endf

  fun! s:grid()
    let l:bufs = s:n_bufs(4)

    silent! only
    exe "buffer" l:bufs[0]
    exe "vert sbuffer" l:bufs[2]
    exe "sbuffer" l:bufs[3]
    wincmd t
    exe "sbuffer" l:bufs[1]
    wincmd t
  endf
  command! Grid call s:grid()

  fun! s:two_col()
    let l:bufs = s:n_bufs(2)

    silent! only
    exe "buffer" l:bufs[0]
    exe "vert sbuffer" l:bufs[1]
    wincmd t
  endf
  command! TwoCol call s:two_col()
  fun! s:two_row()
    let l:bufs = s:n_bufs(2)

    silent! only
    exe "buffer" l:bufs[0]
    exe "sbuffer" l:bufs[1]
    wincmd t
  endf
  command! TwoRow call s:two_row()

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
