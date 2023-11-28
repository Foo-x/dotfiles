let g:previm_open_cmd = 'open'

fun! s:init_markdown()
  nnoremap <silent><buffer> <Leader>x :<C-u>call markdown#SwitchStatus()<CR>
  inoremap <silent><buffer> ;> <C-t>
  inoremap <silent><buffer> ;< <C-d>
endf

augroup Markdown
  autocmd!
  autocmd FileType markdown call s:init_markdown()
augroup END
