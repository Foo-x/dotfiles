cnoreabbr w!! w !sudo tee > /dev/null %
cnoreabbr e% expand('%')

" argument list
cnoreabbr <expr> ar getcmdtype() == ':' && getcmdline() ==# 'ar' ? 'args' : 'ar'
cnoreabbr <expr> ad getcmdtype() == ':' && getcmdline() ==# 'ad' ? 'argdelete' : 'ad'
cnoreabbr <expr> ada getcmdtype() == ':' && getcmdline() ==# 'ada' ? 'argdelete *' : 'ada'
cnoreabbr <expr> add getcmdtype() == ':' && getcmdline() ==# 'add' ? 'argdedupe' : 'add'

cnoremap <expr> ; getcmdtype() == ':' && empty(getcmdline()) ? "\<Esc>q:" : ';'
cnoremap <expr> / getcmdtype() == '/' && empty(getcmdline()) ? "\<Esc>q/" : '/'
cnoremap <expr> ? getcmdtype() == '?' && empty(getcmdline()) ? "\<Esc>q?" : '?'
cnoremap <expr> gd getcmdtype() == ':' && empty(getcmdline()) ? "g//d_\<Left>\<Left>\<Left>" : 'gd'
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

command! -nargs=1 -complete=arglist A b <args>
command! -nargs=* -complete=file -bar AA argadd <args> | argdedupe
command! TabArgs tabnew | silent! argdo tab next
command! -nargs=+ -complete=file EditMultiple silent! argdelete * | AA <args> | TabArgs

command! TabcloseRight +,$tabdo tabclose

" insert_print
if !exists('g:insert_print_prefix')
  let g:insert_print_prefix = '+++++ 🔴🟠🟡🟢🔵🟣🟤 $FILENAME:$LINENO '
endif

if !exists('g:insert_print_suffix')
  let g:insert_print_suffix = ' +++++'
endif

if !exists('g:insert_print_templates')
  let g:insert_print_templates = {}
  " needs `import time`
  let g:insert_print_templates.python = 'print(f"{time.perf_counter()}s {}")'
  let g:insert_print_templates.javascript = 'console.log(`${performance.now() / 1000}s {}`);'
  let g:insert_print_templates.typescript = 'console.log(`${performance.now() / 1000}s {}`);'
  let g:insert_print_templates.typescriptreact = 'console.log(`${performance.now() / 1000}s {}`);'
  let g:insert_print_templates.vue = 'console.log(`${performance.now() / 1000}s {}`);'
  let g:insert_print_templates.lua = 'print(os.clock() .. "s {}")'
endif

if !exists('g:insert_print_text')
  let g:insert_print_text = '$0'
endif

fun! s:insert_print()
  let g:insert_print_cur = get(g:, 'insert_print_cur', 0)
  let g:insert_print_cur += 1

  let l:line_template = get(g:insert_print_templates, &filetype, '{}')
  let l:insert_print_line = substitute(l:line_template, '{}', g:insert_print_prefix . g:insert_print_cur . '. ' . g:insert_print_text . g:insert_print_suffix, '')
  let l:insert_print_line = substitute(l:insert_print_line, '$FILENAME', expand('%'), '')
  let l:insert_print_line = substitute(l:insert_print_line, '$LINENO', line('.') + 1, '')
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
    command! -buffer InsertPrint call s:insert_print()
    nnoremap <buffer> <Space>i :<C-u>InsertPrint<CR>
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
fun! MoveWindow(direction)
  if a:direction !~ '[hjkl]'
    return
  endif

  let l:source_winnr = winnr()
  let l:source_bufnr = bufnr()
  let l:source_line = line('.')
  let l:source_col = col('.')

  exe 'winc' a:direction
  exe 'b' l:source_bufnr
  call cursor(l:source_line, l:source_col)
  winc p
  b#
  winc p
endf

fun! s:autosave()
  if !&modifiable || &readonly || !filewritable(expand('%'))
    return
  endif
  if get(g:, 'autosave', 0) || get(t:, 'autosave', 0) || get(w:, 'autosave', 0) || get(b:, 'autosave', 0)
    silent! update
  endif
endf
augroup AutoSave
  autocmd!
  autocmd CursorHold * call s:autosave()
augroup END
command! AutoSaveToggleGlobal let g:autosave=!get(g:, 'autosave', 0)
command! AutoSaveToggleTab let t:autosave=!get(t:, 'autosave', 0)
command! AutoSaveToggleWindow let w:autosave=!get(w:, 'autosave', 0)
command! AutoSaveToggleBuffer let b:autosave=!get(b:, 'autosave', 0)
command! AutoSaveClear let g:autosave=0 | let t:autosave=0 | let w:autosave=0 | let b:autosave=0
command! AutoSaveInfo echom 'g:' . get(g:, 'autosave', 0) | echom 't:' . get(t:, 'autosave', 0) | echom 'w:' . get(w:, 'autosave', 0) | echom 'b:' . get(b:, 'autosave', 0)

command! CopyFilename let @+=expand('%') | silent! doautocmd TextYankPost
command! CopyFilenameAbsolute let @+=expand('%:p') | silent! doautocmd TextYankPost
command! CopyFilenameBasename let @+=expand('%:t') | silent! doautocmd TextYankPost
command! CopyFilenameBasenameWithoutExtension let @+=expand('%:t:r') | silent! doautocmd TextYankPost
command! CopyFilenameWithCursorPosition let @+=expand('%') . ":" . line('.') . ":" . col('.') | silent! doautocmd TextYankPost
command! CopyFilenameAbsoluteWithCursorPosition let @+=expand('%:p') . ":" . line('.') . ":" . col('.') | silent! doautocmd TextYankPost

" save yanked text to the operator register too
" change -> c, delete -> d, yank -> y
" https://blog.atusy.net/2023/12/17/vim-easy-to-remember-regnames/
fun! s:use_easy_regname()
  if v:event.regname ==# ''
    call setreg(v:event.operator, getreg())
  endif
endf
augroup UseEasyRegname
  autocmd!
  au TextYankPost * call s:use_easy_regname()
augroup END

fun! s:yank_to_clipboard()
  if v:event.regname ==# ''
    call setreg('+', getreg())
  endif
endf
augroup YankToClipboard
  autocmd!
  au TextYankPost * call s:yank_to_clipboard()
augroup END

fun! s:fileinfo()
  let l:path = expand('%:p')
  let l:lines = line('$') . 'L'
  let l:size = trim(execute('w !wc -c | numfmt --to=iec')) . 'B'
  if l:path != ''
    let l:stat = system('stat -c "%A uid=%u(%U) gid=%g(%G) %y" ' . expand('%'))
    echo '"' . l:path . '"' l:lines l:size l:stat
  else
    echo '"[No Name]"' l:lines l:size
  endif

  set ff?
  set fenc?
  set enc?
  set ft?
endf
command! FileInfo call s:fileinfo()

" https://zenn.dev/vim_jp/articles/show-hlgroup-under-cursor
function s:show_highlight_group()
  let hlgroup = synIDattr(synID(line('.'), col('.'), 1), 'name')
  let groupChain = []

  while hlgroup !=# ''
    call add(groupChain, hlgroup)
    let hlgroup = matchstr(trim(execute('highlight ' . hlgroup)), '\<links\s\+to\>\s\+\zs\w\+$')
  endwhile

  if empty(groupChain)
    echo 'No highlight groups'
    return
  endif

  for group in groupChain
    execute 'highlight' group
  endfor
endfunction
command! ShowHighlightGroup call s:show_highlight_group()

command! Typos !typos %
command! TyposAll !typos

if has('nvim')
  command! SignColumnToggle if &signcolumn =~ '^yes' | set signcolumn=no | else | set signcolumn=yes:2 | endif
  command! VirtualTextToggle lua vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
else
  command! SignColumnToggle if &signcolumn =~ '^yes' | set signcolumn=no | else | set signcolumn=yes | endif
endif
