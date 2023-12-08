" options {{{
set rtp+=~/.fzf
" }}}

" keymap {{{
nnoremap <Space>f <Plug>(fzf)
nnoremap <Plug>(fzf)f :<C-u>Files<CR>
nnoremap <Plug>(fzf)e :<C-u>FFern<CR>
nnoremap <Plug>(fzf)g :<C-u>GFiles<CR>
nnoremap <Plug>(fzf)b :<C-u>Buffers<CR>
nnoremap <Plug>(fzf)h :<C-u>HistoryWS<CR>
nnoremap <Plug>(fzf)H :<C-u>History<CR>
nnoremap <Plug>(fzf)ar :<C-u>Args<CR>
nnoremap <Plug>(fzf)ad :<C-u>DeleteArgs<CR>
nnoremap <Plug>(fzf)aa :<C-u>AddArgs<CR>
nnoremap <Plug>(fzf)ag :<C-u>GAddArgs<CR>
" }}}

" command {{{
cnoreabbr FF Files
cnoreabbr FG GFiles
cnoreabbr FB Buffers
cnoreabbr FH HistoryWS
cnoreabbr FHA History
cnoreabbr FHE Helptags
cnoreabbr FA Args

" skip on vim-tiny
if 1
  fun! s:fzf_delete_buffers(command, lines)
    let l:bufnrs = map(filter(a:lines, 'len(v:val)'), {_, line -> split(split(line, '	')[-2],'[\[\]]')[0]})
    call DeleteBuffers(a:command, l:bufnrs)
  endf

  command! FBD call fzf#vim#buffers(fzf#vim#with_preview({
    \ 'sink*': { lines -> s:fzf_delete_buffers('bdelete', lines) },
    \ 'options': '--multi --reverse --bind ctrl-a:select-all --prompt "FBD> "'
  \ }))

  command! FBW call fzf#vim#buffers(map(getbufinfo(), 'v:val.bufnr'), fzf#vim#with_preview({
    \ 'sink*': { lines -> s:fzf_delete_buffers('bwipeout', lines) },
    \ 'options': '--multi --reverse --bind ctrl-a:select-all --prompt "FBW> "'
  \ }))

  command! Args call fzf#run(fzf#wrap(fzf#vim#with_preview({'source': argv(), 'options': '--prompt "Args> "'}), 0))
  command! History call fzf#run(fzf#wrap(fzf#vim#with_preview({'source': filter(copy(v:oldfiles[1:]), 'filereadable(v:val)'), 'options': '--prompt "History> "'}), 0))
  command! HistoryWS call fzf#run(fzf#wrap(fzf#vim#with_preview({'source': filter(copy(v:oldfiles[1:]), 'filereadable(v:val) && v:val =~ "^" . getcwd()'), 'options': '--prompt "HistoryWS> "'}), 0))
  fun! s:fzf_argdelete(lines)
    let l:args = join(map(a:lines, 'fnameescape(v:val)'))
    exe 'argdelete' l:args
  endf
  command! DeleteArgs call fzf#run(fzf#wrap(fzf#vim#with_preview({
    \ 'source': argv(),
    \ 'sink*': { lines -> s:fzf_argdelete(lines) },
    \ 'options': '--multi --bind ctrl-a:select-all --prompt "DeleteArgs> "'
  \ }), 0))
  fun! s:fzf_argadd(lines, should_update)
    if a:should_update
      argdelete *
    endif
    let l:args = join(map(a:lines, 'fnameescape(v:val)'))
    exe 'argadd' l:args | argdedupe
  endf
  command! -bang AddArgs call fzf#vim#files(<q-args>, fzf#vim#with_preview({
    \ 'sink*': { lines -> s:fzf_argadd(lines, <bang>0) },
    \ 'options': '--multi --bind ctrl-a:select-all --prompt "AddArgs> "'
  \ }))
  command! -bang GAddArgs call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview({
    \ 'sink*': { lines -> s:fzf_argadd(lines, <bang>0) },
    \ 'options': '--multi --bind ctrl-a:select-all --prompt "GAddArgs> "'
  \ }))

  fun! s:open_buffers_in_new_tab(is_vert, lines)
    let l:lines = map(filter(a:lines, 'len(v:val)'), {_, line -> split(line, '	')[-1]})
    echom l:lines
    exe 'tabnew' fnameescape(l:lines[0])
    if len(l:lines) == 1
      return
    endif

    for l:file in l:lines[1:]
      if a:is_vert
        exe 'vsplit' fnameescape(l:file)
      else
        exe 'split' fnameescape(l:file)
      endif
    endfor
    winc t
  endf

  command! -bang TS call fzf#vim#files(<q-args>, fzf#vim#with_preview({
    \ 'sink*': { lines -> s:open_buffers_in_new_tab(0, lines) },
    \ 'options': '--multi --bind ctrl-a:select-all --prompt "TS> "'
  \ }))
  command! -bang TV call fzf#vim#files(<q-args>, fzf#vim#with_preview({
    \ 'sink*': { lines -> s:open_buffers_in_new_tab(1, lines) },
    \ 'options': '--multi --bind ctrl-a:select-all --prompt "TV> "'
  \ }))
  command! -bang BTS call fzf#vim#buffers(<q-args>, fzf#vim#with_preview({
    \ 'sink*': { lines -> s:open_buffers_in_new_tab(0, lines) },
    \ 'options': '--multi --bind ctrl-a:select-all --prompt "BTS> "'
  \ }))
  command! -bang BTV call fzf#vim#buffers(<q-args>, fzf#vim#with_preview({
    \ 'sink*': { lines -> s:open_buffers_in_new_tab(1, lines) },
    \ 'options': '--multi --bind ctrl-a:select-all --prompt "BTV> "'
  \ }))
  command! -bang ATS call fzf#run(fzf#wrap(fzf#vim#with_preview({
    \ 'source': argv(),
    \ 'sink*': { lines -> s:open_buffers_in_new_tab(0, lines) },
    \ 'options': '--multi --bind ctrl-a:select-all --prompt "ATS> "'
  \ })))
  command! -bang ATV call fzf#run(fzf#wrap(fzf#vim#with_preview({
    \ 'source': argv(),
    \ 'sink*': { lines -> s:open_buffers_in_new_tab(1, lines) },
    \ 'options': '--multi --bind ctrl-a:select-all --prompt "ATV> "'
  \ })))

  fun! s:fern_reveal(line)
    exe 'Fern . -drawer -reveal=' . a:line
  endf
  command! FFern call fzf#run(fzf#wrap({
    \ 'source': '__bfs_dir',
    \ 'sink': function('s:fern_reveal'),
    \ 'options': '--prompt "FFern> "'
  \ }))
endif
" }}}
