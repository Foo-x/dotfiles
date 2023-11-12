" options {{{
set rtp+=~/.fzf
" }}}

" command {{{
cnoreabbr FF Files
cnoreabbr FGF GFiles
cnoreabbr FB Buffers
cnoreabbr FL Lines
cnoreabbr FBL BLines
cnoreabbr FH History
cnoreabbr FHE Helptags

" skip on vim-tiny
if 1
  fun! s:list_buffers(unlisted = '')
    redir => list
    silent exe 'ls' . a:unlisted
    redir END
    return split(list, "\n")
  endf

  fun! s:fzf_delete_buffers(command, lines)
    let l:bufnrs = map(a:lines, {_, line -> split(split(line)[0],'[^0-9]\+')[0]})
    call s:delete_buffers(a:command, l:bufnrs)
  endf

  command! FBD call fzf#run(fzf#wrap({
    \ 'source': s:list_buffers(),
    \ 'sink*': { lines -> s:fzf_delete_buffers('bdelete', lines) },
    \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
  \ }))

  command! FBW call fzf#run(fzf#wrap({
    \ 'source': s:list_buffers('!'),
    \ 'sink*': { lines -> s:fzf_delete_buffers('bwipeout', lines) },
    \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
  \ }))
endif
" }}}
