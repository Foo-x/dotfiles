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
cnoreabbr FGA GArgs

" skip on vim-tiny
if 1
  fun! s:fzf_delete_buffers(command, lines)
    let l:bufnrs = map(filter(a:lines, 'len(v:val)'), {_, line -> split(split(line, '	')[-2],'[\[\]]')[0]})
    call DeleteBuffers(a:command, l:bufnrs)
  endf

  command! FBD call fzf#vim#buffers(fzf#vim#with_preview({
    \ 'sink*': { lines -> s:fzf_delete_buffers('bdelete', lines) },
    \ 'options': '--multi --reverse --bind ctrl-a:select-all'
  \ }))

  command! FBW call fzf#vim#buffers(map(getbufinfo(), 'v:val.bufnr'), fzf#vim#with_preview({
    \ 'sink*': { lines -> s:fzf_delete_buffers('bwipeout', lines) },
    \ 'options': '--multi --reverse --bind ctrl-a:select-all'
  \ }))

  fun! s:fzf_argadd(lines, should_update)
    if a:should_update
      argdelete *
    endif
    let l:args = join(map(a:lines, 'fnameescape(v:val)'))
    exe 'argadd' l:args | argdedupe
  endf
  command! -bang Args call fzf#vim#files(<q-args>, fzf#vim#with_preview({
    \ 'sink*': { lines -> s:fzf_argadd(lines, <bang>0) },
    \ 'options': '--multi --bind ctrl-a:select-all'
  \ }))
  command! -bang GArgs call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview({
    \ 'sink*': { lines -> s:fzf_argadd(lines, <bang>0) },
    \ 'options': '--multi --bind ctrl-a:select-all'
  \ }))
endif
" }}}
