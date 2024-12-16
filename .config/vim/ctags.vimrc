if !executable('rg') || !executable('ctags')
  finish
endif

augroup Ctags
 autocmd!
 autocmd FileWritePost,BufWritePost * if g:ctags_active | call jobstart('rg --files | ctags -R -L -') | endif
augroup END

let g:ctags_active = filereadable('tags')
command! CtagsInit if !g:ctags_active | call jobstart('rg --files | ctags -R -L -') | let g:ctags_active = v:true | endif
