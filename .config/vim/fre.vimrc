if !executable('fre')
  finish
endif

augroup Fre
  autocmd!
  autocmd VimEnter * autocmd BufWinEnter * if g:fre_active && filereadable(expand('%:~:.')) && bufname() !~ '^\.local/.\+' | call jobstart('fre --store .local/fre.json --add ' . expand('%:~:.') . '&& echo >> .local/fre.json') | endif
augroup END

let g:fre_active = filereadable('.local/fre.json')
command! FreInit if !g:fre_active | call jobstart('fre --store .local/fre.json --add ' . expand('%:~:.') . '&& echo >> .local/fre.json') | let g:fre_active = v:true | endif

nnoremap <Space><Space>f <Cmd>exe 'e .local/fre.json'<CR>
