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
  let g:insert_print_prefix = '+++++ $RANDOM_EMOJI $FILENAME:$LINENO [$CURRENT_INDEX] '
endif

if !exists('g:insert_print_emoji_list')
  let g:insert_print_emoji_list = '😆😇🤔😑😎👻💛💚💙💜💯💥💫💦💤👌👍🙏💪👀🐒🐈🐇🐾🐣🐬🍀🍇🍉🍒🍔🍥🍡🍺🚀🌙🌈🔥💧✨🎈🎉🏀🎲🎨🔔💡📖📝🔰✅🔴🔵🥕🧐🧡🥪🧬🟠🟡🟢🟣🟥🟧🟨🟩🟦🟪🪶🪃'
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
  let g:insert_print_templates.sh = 'date "+%s.%6Ns {}"'
  let g:insert_print_templates.bash = 'date "+%s.%6Ns {}"'
  let g:insert_print_templates.vim = 'echom "{}"'
endif

fun! s:insert_print()
  let l:random_emoji = strcharpart(g:insert_print_emoji_list, rand() % strchars(g:insert_print_emoji_list), 1)

  let g:insert_print_cur = get(g:, 'insert_print_cur', 0)
  let g:insert_print_cur += 1

  let l:insert_print_line = get(g:insert_print_templates, &filetype, '{}')
      \ ->{ l -> l =~ '\$0'
      \   ? substitute(l, '{}', g:insert_print_prefix, '')
      \   : substitute(l, '{}', g:insert_print_prefix . '$0', '') }()
      \ ->substitute('$FILENAME', expand('%'), '')
      \ ->substitute('$LINENO', line('.') + 1, '')
      \ ->substitute('$RANDOM_EMOJI', l:random_emoji, '')
      \ ->substitute('$CURRENT_INDEX', g:insert_print_cur, '')

  put=l:insert_print_line
  norm! ==

  " move cursor to $0
  call search('$0', '', line('.'))
  norm! "_x"_x
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

command! CopyFilename let @"=expand('%') | doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilenameAbsolute let @"=expand('%:p') | silent! doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilenameBasename let @"=expand('%:t') | silent! doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilenameBasenameWithoutExtension let @"=expand('%:t:r') | silent! doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilenameWithCursorPosition let @"=expand('%') . ":" . line('.') . ":" . col('.') | silent! doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilenameAbsoluteWithCursorPosition let @"=expand('%:p') . ":" . line('.') . ":" . col('.') | silent! doautocmd TextYankPost | call YankToClipboard(@")

" save yanked text to the operator register too
" change -> c, delete -> d, yank -> y
" https://blog.atusy.net/2023/12/17/vim-easy-to-remember-regnames/
fun! s:use_easy_regname()
  if get(v:event, 'regname', '_') ==# ''
    call setreg(v:event.operator, getreg())
  endif
endf
augroup UseEasyRegname
  autocmd!
  au TextYankPost * call s:use_easy_regname()
augroup END

fun! YankToClipboard(str)
  if has('nvim')
    call setreg('+', a:str)
  else
    call system('pbcopy', @")
  endif
endf
fun! s:yank_to_clipboard()
  if get(v:event, 'regname', '_') ==# ''
    call YankToClipboard(getreg())
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

fun! s:delete_current_file()
  let l:current_file = expand('%:p')
  if l:current_file == '' || !filereadable(l:current_file)
    echo 'No such file: "' . l:current_file . '"'
    return
  endif

  let l:confirm = confirm('Delete "' . l:current_file . '"?', "&yes\n&No", 2)
  if l:confirm == 1
    let l:alt_bufinfo = getbufinfo('#')
    if len(l:alt_bufinfo) > 0 && l:alt_bufinfo[0].listed
      b#
    else
      bp
    endif
    call delete(l:current_file)
    echo 'Deleted: "' . l:current_file . '"'
  endif
endf
command! DeleteCurrentFile call s:delete_current_file()

command! Typos !typos %
command! TyposAll !typos

let g:aichat_bufnr = -1
fun! s:aichat_output(command) range
  let l:input = getline(a:firstline, a:lastline)
  let l:input_to_command = join(l:input, "\n") . "\n"
  let l:output = split(system(a:command, l:input_to_command), "\n")

  if !bufexists(g:aichat_bufnr)
    let g:aichat_bufnr = bufadd('')
    exe 'vert sbuffer ' . g:aichat_bufnr
    set buftype=nofile
    call setline(1, ['◆入力', ''])
  else
    exe 'vert sbuffer ' . g:aichat_bufnr
    call append(line('$'), ['---', ''])
    call append(line('$'), ['◆入力', ''])
  endif

  call append(line('$'), l:input + [''])
  call append(line('$'), ['◆出力', ''])
  call append(line('$'), l:output + [''])
  $
endf
command! -range AiChat <line1>,<line2>call s:aichat_output('ai')
command! -range AiChatEnglish <line1>,<line2>call s:aichat_output('ai -r english')
command! -range AiChatJapanese <line1>,<line2>call s:aichat_output('ai -r japanese')
command! -range AiChatPolish <line1>,<line2>call s:aichat_output('ai -r polish')

command! Reload source $MYVIMRC

if has('nvim')
  command! SignColumnToggle if &signcolumn =~ '^yes' | set signcolumn=no | else | set signcolumn=yes:2 | endif
  command! VirtualTextToggle lua vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
else
  command! SignColumnToggle if &signcolumn =~ '^yes' | set signcolumn=no | else | set signcolumn=yes | endif
endif
