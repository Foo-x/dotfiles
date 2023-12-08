nnoremap <silent> <Space>e :<C-u>exe 'Fern . -drawer -reveal=% -toggle -width=' . (&columns / 3)<CR>

" skip on vim-tiny
if 1
  let g:fern#renderer = "nerdfont"
  let g:fern#default_hidden = 1
  let g:fern#default_exclude = '\v^%(\.git|node_modules|__pycache__|[Dd]esktop\.ini|Thumbs\.db|\.DS_Store)$|\.pyc$'

  fun! s:init_fern()
    nnoremap <Plug>(fern-close-drawer) :<C-u>FernDo close -drawer -stay<CR>
    nmap <buffer><silent> <Plug>(fern-action-open-and-close)
        \ <Plug>(fern-action-open)
        \ <Plug>(fern-close-drawer)
    nmap <buffer><expr> <Plug>(fern-my-open-or-expand)
        \ fern#smart#leaf(
        \   "<Plug>(fern-action-open-and-close)",
        \   "<Plug>(fern-action-expand)",
        \ )
    nmap <buffer> <CR> <Plug>(fern-my-open-or-expand)
    nmap <buffer> l <Plug>(fern-my-open-or-expand)
    nmap <buffer> D <Plug>(fern-action-remove=)
    nmap <buffer><silent> x <Plug>(fern-action-yank)<Cmd>call system('open ' . getreg('"'))<CR>
    map <buffer> <Tab> <Plug>(fern-action-mark)
  endf

  augroup Fern
    autocmd! *
    autocmd FileType fern call glyph_palette#apply()
    autocmd FileType fern call s:init_fern()
  augroup END
endif
