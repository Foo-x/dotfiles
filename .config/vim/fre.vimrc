if !executable('fre')
  finish
endif

augroup Fre
  autocmd!
  autocmd VimEnter * autocmd BufWinEnter * if &buftype == '' && &bufhidden == '' && bufname() != '.local/fre.json' | call jobstart('fre --store .local/fre.json --add ' . expand('%:~:.')) | endif
augroup END

nnoremap <Space><Space>f <Cmd>exe 'e .local/fre.json'<CR>
