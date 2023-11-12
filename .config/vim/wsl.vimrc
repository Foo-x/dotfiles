if empty($WSL_DISTRO_NAME) | finish | endif

" command {{{
" skip on vim-tiny
if 1
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
" }}}

" autocmd {{{
" skip on vim-tiny
if 1
  augroup WSLYank
    autocmd!
    autocmd TextYankPost * :call system('pbcopy', @")
  augroup END
endif
" }}}

