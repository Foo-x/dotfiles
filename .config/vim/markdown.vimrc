let g:previm_open_cmd = 'open'
let g:previm_show_header = 0

fun! s:init_markdown()
  nnoremap <silent><buffer> <Leader>x <Cmd>ToggleCheckbox<CR>
  inoremap <silent><buffer> <Tab> <C-t>
  inoremap <silent><buffer> <S-Tab> <C-d>
  set shiftwidth=4
endf

augroup Markdown
  autocmd!
  autocmd FileType markdown call s:init_markdown()
augroup END
