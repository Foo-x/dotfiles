if !exists('g:mark_chars')
  let g:mark_chars = map(range(char2nr('a'), char2nr('z')), 'nr2char(v:val)')
endif

fun! s:DelmarksOnCurrentLine()
  let l:m = join(filter(copy(g:mark_chars), 'line("''" . v:val) == line(".")'))
  if !empty(l:m)
    exe 'delmarks' l:m
    echo 'deleted mark' l:m
    return 1
  endif
  return 0
endf
fun! s:AutoMark()
  let l:deleted = s:DelmarksOnCurrentLine()
  if l:deleted == 1
    return
  endif

  if !exists('b:mark_chars_pos')
    let b:mark_chars_pos = 0
  else
    let b:mark_chars_pos = (b:mark_chars_pos + 1) % len(g:mark_chars)
  endif
  execute 'mark' g:mark_chars[b:mark_chars_pos]
  echo 'marked' g:mark_chars[b:mark_chars_pos]
endf

nmap m <Plug>(mark)
nnoremap <Plug>(mark) <Nop>
nnoremap <silent><Plug>(mark)m :<C-u>call <SID>AutoMark()<CR>
nnoremap <Plug>(mark)c :<C-u>delmarks a-z<CR>
nnoremap <Plug>(mark)C :<C-u>delmarks a-zA-Z<CR>
nnoremap <Plug>(mark)j ]`
nnoremap <Plug>(mark)n ]`
nnoremap <Plug>(mark)k [`
nnoremap <Plug>(mark)p [`
nnoremap <Plug>(mark)l :<C-u>exe 'marks' join(g:mark_chars, '')<CR>

" delete all marks after reading buffer
augroup AutoMark
  autocmd!
  autocmd BufReadPost * delmarks!
augroup END
