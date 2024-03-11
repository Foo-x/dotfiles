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
nnoremap <Plug>(git)co :<C-u>Git checkout<Space>
nnoremap <Plug>(git)cb :<C-u>Git cb<Space>
nnoremap <Plug>(git)cc <Cmd>silent !tmux new-window 'git commit; read -n 1 -s -p "press any key to close ..."'<CR>
nnoremap <Plug>(git)cC <Cmd>silent !tmux new-window 'git commit -n; read -n 1 -s -p "press any key to close ..."'<CR>
nnoremap <Plug>(git)ca <Cmd>silent !tmux new-window 'git commit --amend; read -n 1 -s -p "press any key to close ..."'<CR>
nnoremap <Plug>(git)cA <Cmd>silent !tmux new-window 'git commit --amend -n; read -n 1 -s -p "press any key to close ..."'<CR>
nnoremap <Plug>(git)ce <Cmd>silent !tmux new-window 'git commit --amend --no-edit; read -n 1 -s -p "press any key to close ..."'<CR>
nnoremap <Plug>(git)cE <Cmd>silent !tmux new-window 'git commit --amend --no-edit -n; read -n 1 -s -p "press any key to close ..."'<CR>
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
nnoremap <Plug>(git)i <Cmd>exe 'split ' . trim(system('git rev-parse --show-toplevel')) . '/.git/info/exclude'<CR>

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
  cnoreabbr dvhh DiffviewFileHistory % --all
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
  fun! GvRefresh(options)
    if a:options[0] == '--follow'
      exe 'e' a:options[-1]
      exe 'GV!' join(a:options[1:index(a:options, '--') - 1])
      tabclose +
    else
      tabclose
      exe 'GV' join(a:options[1:])
    endif
  endf
  fun! GvUpdate()
    call GvRefresh(split(expand('%'), ' ')[1:])
  endf
  fun! GvToggleOption(option)
    let l:options = split(expand('%'), ' ')[1:]
    if index(l:options, a:option) == -1
      call insert(l:options, a:option, 1)
    else
      call remove(l:options, index(l:options, a:option))
    endif
    call GvRefresh(l:options)
  endf
  fun! GvToggleAll()
    call GvToggleOption('--all')
  endf
  fun! GvToggleNameStatus()
    call GvToggleOption('--name-status')
  endf
  fun! GvToggleDefaultBranch()
    let l:default_branch = trim(system('git db || echo master'))
    call GvToggleOption(l:default_branch . '..@')
  endf
  fun! GvToggleBaseBranch()
    let l:base_branch = trim(system('git bb || git db || echo master'))
    call GvToggleOption(l:base_branch . '..@')
  endf
  augroup Git
    autocmd!
    autocmd FileType fugitive,git,GV setlocal isk+=-
    autocmd FileType fugitive,git,GV nnoremap <buffer><silent> co :<C-u>G checkout <cword><CR>
    autocmd FileType GV nnoremap <buffer><silent> <CR> :<C-u>call feedkeys(".\<lt>C-u>DiffviewOpen\<lt>C-e>^!\<lt>CR>")<CR>
    autocmd FileType GV nnoremap <buffer><silent> u <Cmd>call GvUpdate()<CR>
    autocmd FileType GV nnoremap <buffer><silent> a <Cmd>call GvToggleAll()<CR>
    autocmd FileType GV nnoremap <buffer><silent> d <Cmd>call GvToggleDefaultBranch()<CR>
    autocmd FileType GV nnoremap <buffer><silent> b <Cmd>call GvToggleBaseBranch()<CR>
    autocmd FileType GV nnoremap <buffer><silent> <C-n> <Cmd>call GvToggleNameStatus()<CR>
    autocmd FileType GV nnoremap <buffer><silent> cf :<C-u>G commit --fixup <cword><CR>
    autocmd FileType GV nnoremap <buffer><silent> cF :<C-u>G commit --fixup <cword><CR>:G -c sequence.editor=true rebase -i --autosquash <cword>^<CR>
    autocmd FileType GV nnoremap <buffer><silent> ca :<C-u>G commit --fixup amend:<cword><CR>
    autocmd FileType GV nnoremap <buffer><silent> cA :<C-u>G commit --fixup amend:<cword><CR>:G -c sequence.editor=true rebase -i --autosquash <cword>^<CR>
    autocmd FileType GV nnoremap <buffer><silent> cr :<C-u>G commit --fixup reword:<cword><CR>
    autocmd FileType GV nnoremap <buffer><silent> cR :<C-u>G commit --fixup reword:<cword><CR>:G -c sequence.editor=true rebase -i --autosquash <cword>^<CR>
    autocmd FileType GV nnoremap <buffer><silent> cs :<C-u>G commit --squash <cword><CR>
    autocmd FileType GV nnoremap <buffer><silent> cS :<C-u>G commit --squash <cword><CR>:G rebase -i --autosquash <cword>^<CR>
    autocmd FileType GV nnoremap <buffer><silent> me :<C-u>G merge <cword><CR>
    autocmd FileType diff,git setlocal foldmethod=expr foldexpr=s:diff_fold()
  augroup END
endif
" }}}
