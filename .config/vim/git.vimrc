" options {{{
" skip on vim-tiny
if 1
  " gitgutter
  let g:gitgutter_set_sign_backgrounds=1
  let g:gitgutter_preview_win_floating=0
  let g:gitgutter_sign_priority=20
endif
" }}}

" keymap {{{
nmap <Space><Space>gp <Plug>(GitGutterPreviewHunk)<C-w>P
nnoremap <C-j> <Plug>(GitGutterNextHunk)
nnoremap <C-k> <Plug>(GitGutterPrevHunk)
nnoremap <F9> :<C-u>GV --all<CR>
nnoremap <S-F9> :<C-u>GV --name-status --all<CR>
nnoremap <F10> :<C-u>GV! --all<CR>
" }}}
"
" command {{{
" vim-fugitive
cnoreabbr G tab Git
cnoreabbr GDT G difftool -y
cnoreabbr GMT G mergetool -y \| .,$tabdo on \| Gvdiffsplit! \| winc J \| winc t \| Gvdiffsplit :1 \| winc j

" gv.vim
cnoreabbr GVA GV --all
cnoreabbr GV1 GV --name-status
cnoreabbr GVA1 GV --name-status --all

" diffview.nvim
if has('nvim')
  cnoreabbr DV DiffviewOpen
  cnoreabbr DVH DiffviewFileHistory --all
  cnoreabbr DVH! DiffviewFileHistory % --all
endif
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
  fun! s:diff_fold()
    let l:line = getline(v:lnum)
    if l:line =~ '^\(diff\|---\|+++\|@@\) '
      return 1
    elseif l:line[0] =~ '[-+ ]'
      return 2
    else
      return 0
    endif
  endf
  augroup Git
    autocmd!
    autocmd FileType fugitive,git,GV setlocal isk+=-
    autocmd FileType fugitive,git,GV nnoremap <buffer><silent> cob :<C-u>G checkout <cword><CR>
    autocmd FileType GV nnoremap <buffer><silent> <CR> :<C-u>call feedkeys(".\<lt>C-u>DiffviewOpen\<lt>C-e>^!\<lt>CR>")<CR>
    autocmd FileType diff,git setlocal foldmethod=expr foldexpr=s:diff_fold()
  augroup END
endif
" }}}
