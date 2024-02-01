nnoremap <silent> <Space>e :<C-u>exe 'Fern . -drawer -reveal=% -toggle -width=' . (&columns / 3)<CR>

" skip on vim-tiny
if 1
  let g:fern#renderer = "nerdfont"
  let g:fern#default_hidden = 1
  let g:fern#default_exclude = '\v^%(\.git|node_modules|__pycache__|[Dd]esktop\.ini|Thumbs\.db|\.DS_Store)$|\.pyc$'

  fun! s:init_fern()
    nmap <Plug>(fern-close-drawer) <Cmd>FernDo close -drawer -stay<CR>
    nmap <buffer><silent> <Plug>(fern-action-open-and-close) <Plug>(fern-action-open)<Plug>(fern-close-drawer)
    nmap <buffer><expr> <Plug>(fern-my-open-or-expand)
        \ fern#smart#leaf(
        \   "<Plug>(fern-action-open-and-close)",
        \   "<Plug>(fern-action-expand)",
        \ )
    nnoremap <buffer> <CR> <Plug>(fern-my-open-or-expand)
    nnoremap <buffer> l <Plug>(fern-my-open-or-expand)
    nnoremap <buffer> t <Plug>(fern-action-open:tabedit)gt<Plug>(fern-close-drawer)gT
    nnoremap <buffer> D <Plug>(fern-action-remove=)
    nnoremap <buffer><silent> x <Plug>(fern-action-yank)<Cmd>call system('open ' . getreg('"'))<CR>
    noremap <buffer> <Tab> <Plug>(fern-action-mark)<Down>
  endf

  augroup Fern
    autocmd! *
    autocmd FileType fern call glyph_palette#apply() | call glyph_palette#defaults#highlight()
    autocmd FileType fern call s:init_fern()
  augroup END
endif
