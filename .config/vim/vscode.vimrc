" command {{{
" skip on vim-tiny
if 1
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
endif
" }}}
