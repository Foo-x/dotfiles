cnoreabbr w!! w !sudo tee > /dev/null %

" argument list
cnoreabbr <expr> ar getcmdtype() == ':' && getcmdline() ==# 'ar' ? 'args' : 'ar'
cnoreabbr <expr> ad getcmdtype() == ':' && getcmdline() ==# 'ad' ? 'argdelete' : 'ad'
cnoreabbr <expr> ada getcmdtype() == ':' && getcmdline() ==# 'ada' ? 'argdelete *' : 'ada'
cnoreabbr <expr> add getcmdtype() == ':' && getcmdline() ==# 'add' ? 'argdedupe' : 'add'

cnoremap <expr> ; getcmdtype() == ':' && empty(getcmdline()) ? "\<Esc>q:" : ';'
cnoremap <expr> / getcmdtype() == '/' && empty(getcmdline()) ? "\<Esc>q/" : '/'
cnoremap <expr> ? getcmdtype() == '?' && empty(getcmdline()) ? "\<Esc>q?" : '?'
cnoremap <expr> gdd getcmdtype() == ':' && empty(getcmdline()) ? "g//d_\<Left>\<Left>\<Left>" : 'gd'
cnoremap <expr> e%: getcmdtype() == ':' ? "expand('%:')\<Left>\<Left>" : 'e%:'
cnoremap <expr> e%<Space> getcmdtype() == ':' ? "expand('%') " : 'e%'
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

command! -nargs=1 -complete=arglist A b <args>
command! -nargs=* -complete=file -bar AA argadd <args> | argdedupe
command! TabArgs tabnew | silent! argdo tab next
command! -nargs=+ -complete=file EditMultiple silent! argdelete * | AA <args> | TabArgs
command! NextOrFirst try | next | catch | first | endtry
command! PrevOrLast try | prev | catch | last | endtry

command! TabcloseRight +,$tabdo tabclose

" insert_print
if !exists('g:insert_print_marker')
  " split not to match with grep
  let g:insert_print_marker = '[' . 'INSERT_PRINT' . ']'
endif

if !exists('g:insert_print_prefix')
  let g:insert_print_prefix = '$MARKER $EMOJI $FILENAME:$LINENO [$INDEX] '
endif

if !exists('g:insert_print_emoji_list')
  let g:insert_print_emoji_list = '😆😇🤔😑😎👻💛💚💙💜💯💥💫💦💤👌👍🙏💪👀🐒🐈🐇🐾🐣🐬🍀🍇🍉🍒🍔🍥🍡🍺🚀🌙🌈🔥💧✨🎈🎉🏀🎲🎨🔔💡📖📝🔰✅🔴🔵🥕🧐🧡🥪🧬🟠🟡🟢🟣🟥🟧🟨🟩🟦🟪🪶🪃'
endif

if !exists('g:insert_print_timestamp')
  let g:insert_print_timestamp = {}
  " needs `from datetime import datetime`
  let g:insert_print_timestamp.python = 'datetime.now().strftime("%H:%M:%S.%f")[:-3]'
  let g:insert_print_timestamp.javascript = 'new Date().toISOString().slice(11,-1)'
  let g:insert_print_timestamp.typescript = 'new Date().toISOString().slice(11,-1)'
  let g:insert_print_timestamp.typescriptreact = 'new Date().toISOString().slice(11,-1)'
  let g:insert_print_timestamp.vue = 'new Date().toISOString().slice(11,-1)'
  let g:insert_print_timestamp.lua = 'os.date("%H:%M:%S") .. " " .. os.clock()'
  let g:insert_print_timestamp.vim = 'trim(system("date +%T.%3N"))'
  let g:insert_print_timestamp.sh = 'date +%T.%3N'
  let g:insert_print_timestamp.bash = 'date +%T.%3N'
endif

if !exists('g:insert_print_templates')
  let g:insert_print_templates = {}
  let g:insert_print_templates.python = 'print($TIMESTAMP + f" {}")'
  let g:insert_print_templates.javascript = 'console.debug(`${$TIMESTAMP} {}`);'
  let g:insert_print_templates.typescript = 'console.debug(`${$TIMESTAMP} {}`);'
  let g:insert_print_templates.typescriptreact = 'console.debug(`${$TIMESTAMP} {}`);'
  let g:insert_print_templates.vue = 'console.debug(`${$TIMESTAMP} {}`);'
  let g:insert_print_templates.lua = 'print($TIMESTAMP .. " {}")'
  let g:insert_print_templates.vim = 'echom $TIMESTAMP . " {}"'
  let g:insert_print_templates.sh = 'printf "%s {}\n" $($TIMESTAMP)'
  let g:insert_print_templates.bash = 'printf "%s {}\n" $($TIMESTAMP)'
endif

fun! s:insert_print()
  let l:emoji = strcharpart(g:insert_print_emoji_list, rand() % strchars(g:insert_print_emoji_list), 1)

  let s:insert_print_index = get(s:, 'insert_print_index', 0)
  let s:insert_print_index += 1

  let l:insert_print_line = get(g:insert_print_templates, &filetype, '{}')
      \ ->{ l -> l =~ '\$0'
      \   ? substitute(l, '{}', g:insert_print_prefix, '')
      \   : substitute(l, '{}', g:insert_print_prefix . '$0', '') }()
      \ ->substitute('$MARKER', g:insert_print_marker, '')
      \ ->substitute('$FILENAME', expand('%'), '')
      \ ->substitute('$LINENO', line('.') + 1, '')
      \ ->substitute('$EMOJI', l:emoji, '')
      \ ->substitute('$INDEX', s:insert_print_index, '')
      \ ->substitute('$TIMESTAMP', get(g:insert_print_timestamp, &filetype, ''), '')

  put=l:insert_print_line
  norm! ==

  " move cursor to $0
  call search('$0', '', line('.'))
  norm! "_x"_x
endf
fun! s:clean_insert_print()
  wall
  exe 'silent grep! -F ' . g:insert_print_marker
  cdo delete
  cfdo update
  cclose
endf
command! CleanInsertPrint call s:clean_insert_print()
command! CleanInsertPrintInCurrentBuffer update | exe 'g/\V' . g:insert_print_marker . '/d' | update
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
command! AutoSaveEnableGlobal let g:autosave=1
command! AutoSaveEnableTab let t:autosave=1
command! AutoSaveEnableWindow let w:autosave=1
command! AutoSaveEnableBuffer let b:autosave=1
command! AutoSaveDisableGlobal let g:autosave=0
command! AutoSaveDisableTab let t:autosave=0
command! AutoSaveDisableWindow let w:autosave=0
command! AutoSaveDisableBuffer let b:autosave=0
command! AutoSaveToggleGlobal let g:autosave=!get(g:, 'autosave', 0)
command! AutoSaveToggleTab let t:autosave=!get(t:, 'autosave', 0)
command! AutoSaveToggleWindow let w:autosave=!get(w:, 'autosave', 0)
command! AutoSaveToggleBuffer let b:autosave=!get(b:, 'autosave', 0)
command! AutoSaveClear let g:autosave=0 | let t:autosave=0 | let w:autosave=0 | let b:autosave=0
command! AutoSaveInfo echom 'g:' . get(g:, 'autosave', 0) | echom 't:' . get(t:, 'autosave', 0) | echom 'w:' . get(w:, 'autosave', 0) | echom 'b:' . get(b:, 'autosave', 0)

command! CopyDirname let @"=expand('%:h') | doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilename let @"=expand('%') | doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilenameAbsolute let @"=expand('%:p') | silent! doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilenameBasename let @"=expand('%:t') | silent! doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilenameBasenameWithoutExtension let @"=expand('%:t:r') | silent! doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilenameWithCursorPosition let @"=expand('%') . ":" . line('.') . ":" . col('.') | silent! doautocmd TextYankPost | call YankToClipboard(@")
command! CopyFilenameAbsoluteWithCursorPosition let @"=expand('%:p') . ":" . line('.') . ":" . col('.') | silent! doautocmd TextYankPost | call YankToClipboard(@")

function! s:add_bookmark()
  if empty(expand('%:p'))
    return
  endif

  let l:file = expand('%')
  let l:bookmark_file = expand('.local/bookmarks.txt')

  call mkdir(fnamemodify(l:bookmark_file, ':h'), 'p')

  call writefile([l:file], l:bookmark_file, 'a')

  echom 'Bookmarked: ' . l:file
endfunction
command! AddBookmark call s:add_bookmark()

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

fun! s:kanbanmd()
  set equalalways

  tabnew

  tcd $XDG_DATA_HOME/kanbanmd

  e 1_backlog.md
  sp 4_blocked.md
  vs 5_done.md
  winc t
  vs 2_ready.md
  vs 3_doing.md

  let t:autosave=v:true

  set noequalalways
endf
command! Kanbanmd call s:kanbanmd()
nnoremap <Space><Space>k <Cmd>Kanbanmd<CR>

fun! FocusMax()
  resize

  let l:qf_win = getqflist({'winid': 0})
  if !empty(l:qf_win) && l:qf_win.winid != 0
    call win_execute(l:qf_win.winid, 'resize 10')
  endif

  if t:focus_max
    echo 'FocusMax on'
  else
    echo 'FocusMax off'
  endif
endf
command! ToggleFocusMax let t:focus_max = !get(t:, 'focus_max', v:false) | call FocusMax()

command! Reload source $MYVIMRC

command! QfGitDiff cexpr system('git jump --stdout diff')
command! QfTypos cexpr system('typos --format brief')

command! Pin if get(w:, 'pin', '!') == expand('%') | unlet w:pin | else | let w:pin = expand('%') | endif
command! BackToPin exe 'e ' . w:pin

fun! s:pin_all()
  for l:win in getwininfo()->filter('v:val.tabnr == tabpagenr()')
    call win_execute(l:win.winid, 'let w:pin = expand("%")')
  endfor
endf
command! PinAll call s:pin_all()
cnoreabbr pa PinAll

if has('nvim')
  command! SignColumnToggle if &signcolumn =~ '^yes' | set signcolumn=no | else | set signcolumn=yes:2 | endif
else
  command! SignColumnToggle if &signcolumn =~ '^yes' | set signcolumn=no | else | set signcolumn=yes | endif
endif
