" options {{{
set switchbuf+=useopen
" }}}

" keymap {{{
nmap <Space>b [buffer]
nnoremap [buffer]h <C-^>
nnoremap [buffer]l :<C-u>ls<CR>
nnoremap [buffer]L :<C-u>ls!<CR>
nnoremap <silent> [buffer]j :<C-u>bnext<CR>
nnoremap <silent> [buffer]k :<C-u>bprevious<CR>
nnoremap <silent> [buffer]x :<C-u>bdelete<CR>
" }}}

" command {{{
cnoreabbr BD bn\|bd#
cnoreabbr BW bn\|bw#

" skip on vim-tiny
if 1
  command! BufOnly silent! %bd|e#|bd#
  command! TQ if tabpagenr('$') > 1 | tabclose | else | qa | endif
  command! -bar WUP windo update
  cnoreabbr WQ WUP \| TQ

  fun! s:delete_buffers(command, bufnrs)
    let l:bufnames = map(copy(a:bufnrs), {_, val -> bufname(str2nr(val))})
    silent! execute 'argdelete' join(l:bufnames)
    execute a:command join(a:bufnrs)
  endf

  fun! s:clean_nonexistent_buffers()
    let l:nonexistent_buffers = map(filter(getbufinfo({'buflisted':1}), '!filereadable(expand(v:val.name))'), 'v:val.bufnr')
    call s:delete_buffers('bwipeout', l:nonexistent_buffers)
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
    exe "buffer" s:bufs[0]
    exe "vert sbuffer" s:bufs[2]
    exe "sbuffer" s:bufs[3]
    wincmd t
    exe "sbuffer" s:bufs[1]
    wincmd t
  endf
  command! Grid call s:grid()

  fun! s:two_col()
    let s:bufs = s:n_bufs(2)

    silent! only
    exe "buffer" s:bufs[0]
    exe "vert sbuffer" s:bufs[1]
    wincmd t
  endf
  command! TwoCol call s:two_col()
  fun! s:two_row()
    let s:bufs = s:n_bufs(2)

    silent! only
    exe "buffer" s:bufs[0]
    exe "sbuffer" s:bufs[1]
    wincmd t
  endf
  command! TwoRow call s:two_row()
endif
" }}}
