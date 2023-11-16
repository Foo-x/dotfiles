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
endif
