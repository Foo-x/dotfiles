" options {{{
" skip on vim-tiny
if 1
  " gitgutter
  let g:gitgutter_set_sign_backgrounds=1
  let g:gitgutter_preview_win_floating=0
endif
" }}}

" keymap {{{
nmap <Space><Space>gj <Plug>(GitGutterNextHunk)
nmap <Space><Space>gk <Plug>(GitGutterPrevHunk)
nmap <Space><Space>gp <Plug>(GitGutterPreviewHunk)<C-w>P
" }}}
"
" command {{{
" vim-fugitive
cnoreabbr G tab Git
cnoreabbr GDT G difftool -y
cnoreabbr GMT G mergetool -y \| .,$tabdo on \| Gvdiffsplit! \| winc J \| winc t \| Gvdiffsplit :1 \| winc j

" gv.vim
cnoreabbr GV0a GV --all
cnoreabbr GV1 GV --name-status
cnoreabbr GV1a GV --name-status --all
" }}}

" autocmd {{{
" skip on vim-tiny
if 1
  augroup GitSpellCheck
    autocmd!
    autocmd FileType gitcommit setlocal spell
  augroup END
  augroup Fugitive
    autocmd!
    autocmd FileType fugitive nnoremap <buffer><silent> <Tab> :<C-u>norm =<CR>
    autocmd FileType fugitive nnoremap <buffer><silent> s :<C-u>norm -<CR>
  augroup END
endif 
" }}}
