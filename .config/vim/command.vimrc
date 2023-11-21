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

  " insert_print
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
    let g:insert_print_levels.info = '📝 ' . '[INFO] $0'
    let g:insert_print_levels.warn = '🔔 ' . '[WARN] $0'
    let g:insert_print_levels.error = '👺 ' . '[ERROR] $0'
  endif

  fun! s:insert_print(level)
    let b:insert_print_cur = get(b:, 'insert_print_cur', 0)
    let b:insert_print_cur += 1

    let l:line_template = get(g:insert_print_templates, &filetype, '{}')
    let l:insert_print_line = substitute(l:line_template, '{}', g:insert_print_prefix . b:insert_print_cur . '. ' . get(g:insert_print_levels, a:level) . g:insert_print_suffix, '')
    put=l:insert_print_line
    norm! ==
    " move cursor to $0 or eol
    if search('$0', '', line('.'))
      norm! "_x"_x
    else
      norm! $
    endif
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

  fun! SwapWindow(direction)
    if a:direction !~ '[hjkl]'
      return
    endif

    let l:source_winnr = winnr()
    let l:source_bufnr = bufnr()
    let l:source_line = line('.')
    let l:source_col = col('.')

    exe 'winc' a:direction
    let l:target_winnr = winnr()
    if l:target_winnr == l:source_winnr
      return
    endif
    let l:target_bufnr = bufnr()
    let l:target_line = line('.')
    let l:target_col = col('.')

    exe 'b' l:source_bufnr
    call cursor(l:source_line, l:source_col)
    winc p
    exe 'b' l:target_bufnr
    call cursor(l:target_line, l:target_col)
    winc p
  endf
endif
