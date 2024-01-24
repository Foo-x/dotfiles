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
nmap <Space>g <Plug>(git)
nnoremap <Plug>(git) <Plug>(GitGutterPreviewHunk)<C-w>P
nnoremap <Plug>(git)<Space> :<C-u>tab Git<Space>
nnoremap <Plug>(git)cc <Cmd>tab Git commit<CR>
nnoremap <Plug>(git)ca <Cmd>tab Git commit --amend<CR>
nnoremap <Plug>(git)ce <Cmd>Git commit --amend --no-edit<CR>
nnoremap <Plug>(git)b <Cmd>Git branch<CR>
nnoremap <Plug>(git)ba <Cmd>Git branch -a<CR>
nnoremap <Plug>(git)bv <Cmd>Git branch -avv<CR>
nnoremap <Plug>(git)s <Cmd>Git status -sb<CR>
nnoremap <Plug>(git)f <Cmd>Git fetch<CR>
nnoremap <Plug>(git)p <Cmd>Git pull<CR>
nnoremap <Plug>(git)pp <Cmd>Git pp<CR>
nnoremap <Plug>(git)ps <Cmd>Git push<CR>
nnoremap <Plug>(git)ss <Cmd>Git stash<CR>
nnoremap <Plug>(git)sl <Cmd>Git stash list<CR>
nnoremap <Plug>(git)sd <Cmd>Git stash drop<CR>
nnoremap <Plug>(git)sp <Cmd>Git stash pop<CR>

nnoremap <C-j> <Plug>(GitGutterNextHunk)
nnoremap <C-k> <Plug>(GitGutterPrevHunk)
nnoremap <F9> :<C-u>GV --all<CR>
nnoremap <S-F9> :<C-u>GV --name-status --all<CR>
nnoremap <F10> :<C-u>GV! --all<CR>
" }}}
"
" command {{{
" vim-fugitive
cnoreabbr <expr> G getcmdtype() == ':' && getcmdline() ==# 'G' ? 'tab Git' : 'G'
cnoreabbr gdt G difftool -y
cnoreabbr gmt G mergetool -y \| .,$tabdo on \| Gvdiffsplit! \| winc J \| winc t \| Gvdiffsplit :1 \| winc j

" gv.vim
cnoreabbr gva GV --all
cnoreabbr gv1 GV --name-status
cnoreabbr gva1 GV --name-status --all

" diffview.nvim
if has('nvim')
  cnoreabbr dv DiffviewOpen
  cnoreabbr dvh DiffviewFileHistory --all
  cnoreabbr dvh! DiffviewFileHistory % --all
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
