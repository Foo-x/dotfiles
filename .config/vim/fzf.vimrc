" options {{{
set rtp+=~/.fzf
" }}}

" command {{{
cnoreabbr FF Files
cnoreabbr FG GFiles
cnoreabbr FB Buffers
cnoreabbr FL Lines
cnoreabbr FBL BLines
cnoreabbr FH History
cnoreabbr FHE Helptags
cnoreabbr FA Args

" skip on vim-tiny
if 1
  fun! s:fzf_delete_buffers(command, lines)
    let l:bufnrs = map(a:lines, {_, line -> split(split(line)[0],'[^0-9]\+')[0]})
    call DeleteBuffers(a:command, l:bufnrs)
  endf

  command! FBD call fzf#vim#buffers(fzf#vim#with_preview({
    \ 'sink*': { lines -> s:fzf_delete_buffers('bdelete', lines) },
    \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
  \ }))

  command! FBW call fzf#vim#buffers(map(getbufinfo(), 'v:val.bufnr'), fzf#vim#with_preview({
    \ 'sink*': { lines -> s:fzf_delete_buffers('bwipeout', lines) },
    \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
  \ }))

  command! Args call fzf#run(fzf#wrap(fzf#vim#with_preview({'source': argv()}), 0))
endif
" }}}
