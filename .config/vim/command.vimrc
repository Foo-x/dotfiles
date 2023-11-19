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

  if !exists('g:insert_print_prefix')
    let g:insert_print_prefix = '+++++ '
  endif

  if !exists('g:insert_print_suffix')
    let g:insert_print_suffix = ' +++++'
  endif

  if !exists('g:insert_print_templates')
    let g:insert_print_templates = {}
    let g:insert_print_templates.python = 'print(f"{}")'
    let g:insert_print_templates.javascript = 'console.log(`{}`);'
    let g:insert_print_templates.typescript = 'console.log(`{}`);'
    let g:insert_print_templates.typescriptreact = 'console.log(`{}`);'
  endif

  if !exists('g:insert_print_levels')
    let g:insert_print_levels = {}
    let g:insert_print_levels.info = '📝 ' . '[INFO] '
    let g:insert_print_levels.warn = '🔔 ' . '[WARN] '
    let g:insert_print_levels.error = '👺 ' . '[ERROR] '
  endif

  fun! s:insert_print(level)
    let b:insert_print_cur = get(b:, 'insert_print_cur', 0)
    let b:insert_print_cur += 1

    let l:line_template = get(g:insert_print_templates, &filetype, '{}')
    let l:insert_print_line = substitute(l:line_template, '{}', g:insert_print_prefix . b:insert_print_cur . '. ' . get(g:insert_print_levels, a:level) . g:insert_print_suffix, '')
    exe 'norm o' . l:insert_print_line
  endf
  fun! s:init_insert_print()
    if has_key(g:insert_print_templates, &filetype)
      command! -buffer InsertPrintInfo call s:insert_print('info')
      command! -buffer InsertPrintWarn call s:insert_print('warn')
      command! -buffer InsertPrintError call s:insert_print('error')
    endif
  endf
  augroup InsertPrint
    autocmd!
    autocmd FileType * call s:init_insert_print()
  augroup END
endif
