cnoreabbr w!! w !sudo tee > /dev/null %

" argument list
cnoreabbr A args
cnoreabbr AD argdelete
cnoreabbr AD. %argdelete
cnoreabbr ADA argdelete *
cnoreabbr ADD argdedupe

" skip on vim-tiny
if 1
  command! -nargs=+ -complete=file -bar AA argadd <args> | argdedupe
  command! TabArgs tabnew | silent! argdo tab next
  command! -nargs=+ -complete=file EditMultiple silent! argdelete * | AA <args> | TabArgs

  command! TabcloseRight +,$tabdo tabclose

  " keywordprg
  fun! s:KeywordHelp(keyword)
    exe "help" a:keyword
  endf
  nnoremap <silent> KH :<C-u>call <SID>KeywordHelp(expand("<cword>"))<CR>
  vnoremap KH "zy:call <SID>KeywordHelp(@z)<CR>

  fun! s:KeywordGoogle(keyword)
    exe "!open 'https://www.google.co.jp/search?q=" . a:keyword . "'"
  endf
  nnoremap KG :<C-u>call <SID>KeywordGoogle(expand("<cword>"))<CR><CR>
  vnoremap KG "zy:call <SID>KeywordGoogle(@z)<CR><CR>
endif
