fun! s:init_markdown()
  nnoremap <silent><buffer> <Leader>x :<C-u>call markdown#SwitchStatus()<CR>
  inoremap <silent><buffer> <Tab> <C-t>
  inoremap <silent><buffer> <S-Tab> <C-d>
endf

augroup Markdown
  autocmd!
  autocmd FileType markdown call s:init_markdown()
augroup END
