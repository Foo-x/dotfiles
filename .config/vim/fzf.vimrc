" keymap {{{
nnoremap <Space>f <Plug>(fzf)
nnoremap <Plug>(fzf)<CR> :<C-u>Files<CR>
"" files in git status
nnoremap <Plug>(fzf)? :<C-u>GFiles?<CR>
nnoremap <Plug>(fzf)g :<C-u>GFiles<CR>
nnoremap <Plug>(fzf). <Cmd>call <SID>files_cursor()<CR>
nnoremap <Plug>(fzf)i :<C-u>FilesNoIgnore<CR>
nnoremap <Plug>(fzf)h :<C-u>HistoryWS<CR>
nnoremap <Plug>(fzf)H :<C-u>History<CR>
nnoremap <Plug>(fzf)ar :<C-u>Args<CR>
nnoremap <Plug>(fzf)ad :<C-u>DeleteArgs<CR>
nnoremap <Plug>(fzf)aa :<C-u>AddArgs<CR>
nnoremap <Plug>(fzf)ag :<C-u>GAddArgs<CR>
nnoremap <Plug>(fzf)b :<C-u>Bookmarks<CR>

vnoremap <Space>f <Plug>(fzf)
vnoremap <Plug>(fzf). <Esc><Cmd>normal gv<CR><Cmd>call <SID>files_cursor()<CR>
" }}}

" command {{{
cnoreabbr <expr> fg getcmdtype() == ':' && getcmdline() ==# 'fg' ? 'GFiles' : 'fg'
cnoreabbr <expr> f? getcmdtype() == ':' && getcmdline() ==# 'f?' ? 'GFiles?' : 'f?'
cnoreabbr <expr> ff getcmdtype() == ':' && getcmdline() ==# 'ff' ? 'Files' : 'ff'
cnoreabbr <expr> fi getcmdtype() == ':' && getcmdline() ==# 'fi' ? 'FilesNoIgnore' : 'fi'
cnoreabbr <expr> fh getcmdtype() == ':' && getcmdline() ==# 'fh' ? 'HistoryWS' : 'fh'
cnoreabbr <expr> fha getcmdtype() == ':' && getcmdline() ==# 'fha' ? 'History' : 'fha'
cnoreabbr <expr> fhe getcmdtype() == ':' && getcmdline() ==# 'fhe' ? 'Helptags' : 'fhe'
cnoreabbr <expr> fa getcmdtype() == ':' && getcmdline() ==# 'fa' ? 'Args' : 'fa'
cnoreabbr <expr> ts getcmdtype() == ':' && getcmdline() ==# 'ts' ? 'TS' : 'ts'
cnoreabbr <expr> tv getcmdtype() == ':' && getcmdline() ==# 'tv' ? 'TV' : 'tv'
cnoreabbr <expr> gts getcmdtype() == ':' && getcmdline() ==# 'gts' ? 'GTS' : 'gts'
cnoreabbr <expr> gtv getcmdtype() == ':' && getcmdline() ==# 'gtv' ? 'GTV' : 'gtv'
cnoreabbr <expr> ats getcmdtype() == ':' && getcmdline() ==# 'ats' ? 'ATS' : 'ats'
cnoreabbr <expr> atv getcmdtype() == ':' && getcmdline() ==# 'atv' ? 'ATV' : 'atv'

fun! s:fzf_delete_buffers(command, lines)
  let l:bufnrs = map(filter(a:lines, 'len(v:val)'), {_, line -> split(split(line, '	')[-2],'[\[\]]')[0]})
  call DeleteBuffers(a:command, l:bufnrs)
endf

command! FBD call fzf#vim#buffers(fzf#vim#with_preview({
  \ 'sink*': { lines -> s:fzf_delete_buffers('bdelete', lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all --prompt "FBD> "'
\ }))

command! FBW call fzf#vim#buffers(map(getbufinfo(), 'v:val.bufnr'), fzf#vim#with_preview({
  \ 'sink*': { lines -> s:fzf_delete_buffers('bwipeout', lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all --prompt "FBW> "'
\ }))

command! Args call fzf#run(fzf#wrap(fzf#vim#with_preview({'source': argv(), 'options': '--prompt "Args> "'}), 0))
command! History call fzf#run(fzf#wrap(fzf#vim#with_preview({'source': filter(copy(v:oldfiles[1:]), 'filereadable(v:val)'), 'options': '--prompt "History> "'}), 0))
command! HistoryWS call fzf#run(fzf#wrap(fzf#vim#with_preview({'source': filter(copy(v:oldfiles[1:]), 'filereadable(v:val) && v:val =~ "^" . getcwd()'), 'options': '--prompt "HistoryWS> "'}), 0))
fun! s:fzf_argdelete(lines)
  let l:args = join(map(a:lines, 'fnameescape(v:val)'))
  exe 'argdelete' l:args
endf
command! DeleteArgs call fzf#run(fzf#wrap(fzf#vim#with_preview({
  \ 'source': argv(),
  \ 'sink*': { lines -> s:fzf_argdelete(lines) },
  \ 'options': '--multi --bind ctrl-a:select-all --prompt "DeleteArgs> "'
\ }), 0))
fun! s:fzf_argadd(lines, should_update)
  if a:should_update
    argdelete *
  endif
  let l:args = join(map(a:lines, 'fnameescape(v:val)'))
  exe 'argadd' l:args | argdedupe
endf
command! -bang AddArgs call fzf#vim#files(<q-args>, fzf#vim#with_preview({
  \ 'sink*': { lines -> s:fzf_argadd(lines, <bang>0) },
  \ 'options': '--multi --bind ctrl-a:select-all --prompt "AddArgs> "'
\ }))
command! -bang GAddArgs call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview({
  \ 'sink*': { lines -> s:fzf_argadd(lines, <bang>0) },
  \ 'options': '--multi --bind ctrl-a:select-all --prompt "GAddArgs> "'
\ }))
command! FilesNoIgnore let _fzf_default_command_tmp=$FZF_DEFAULT_COMMAND | let $FZF_DEFAULT_COMMAND='fd --hidden -tf -tl -I' | exe 'Files' | let $FZF_DEFAULT_COMMAND=_fzf_default_command_tmp

fun! s:open_buffers_in_new_tab(is_vert, lines)
  let l:lines = map(filter(a:lines, 'len(v:val)'), {_, line -> split(line, '	')[-1]})
  echom l:lines
  exe 'tabnew' fnameescape(l:lines[0])
  if len(l:lines) == 1
    return
  endif

  for l:file in l:lines[1:]
    if a:is_vert
      exe 'vsplit' fnameescape(l:file)
    else
      exe 'split' fnameescape(l:file)
    endif
  endfor
  winc t
endf

fun! s:files_cursor()
  if mode() == 'v'
    let l:selected = join(getregion(getpos("'<"), getpos("'>")), '')
    call fzf#vim#files('', fzf#vim#with_preview({
      \ 'options': '--query ' . l:selected
    \ }))
    return
  endif
  call fzf#vim#files('', fzf#vim#with_preview({
    \ 'options': '--query ' . expand('<cword>')
  \ }))
endf

fun! s:gf(line)
  let l:file = split(a:line, '[^[:fname:]]\+')
  let l:filename = l:file[0]
  let l:line = get(l:file, 1, 0)
  let l:column = get(l:file, 2, 0)
  exe 'e ' . l:filename
  if l:line != 0
    call cursor(l:line, l:column)
  endif
endf

command! -bang TS call fzf#vim#files(<q-args>, fzf#vim#with_preview({
  \ 'sink*': { lines -> s:open_buffers_in_new_tab(0, lines) },
  \ 'options': '--multi --bind ctrl-a:select-all --prompt "TS> "'
\ }))
command! -bang TV call fzf#vim#files(<q-args>, fzf#vim#with_preview({
  \ 'sink*': { lines -> s:open_buffers_in_new_tab(1, lines) },
  \ 'options': '--multi --bind ctrl-a:select-all --prompt "TV> "'
\ }))
command! -bang GTS call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview({
  \ 'sink*': { lines -> s:open_buffers_in_new_tab(0, lines) },
  \ 'options': '--multi --bind ctrl-a:select-all --prompt "GTS> "'
\ }))
command! -bang GTV call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview({
  \ 'sink*': { lines -> s:open_buffers_in_new_tab(1, lines) },
  \ 'options': '--multi --bind ctrl-a:select-all --prompt "GTV> "'
\ }))
command! -bang ATS call fzf#run(fzf#wrap(fzf#vim#with_preview({
  \ 'source': argv(),
  \ 'sink*': { lines -> s:open_buffers_in_new_tab(0, lines) },
  \ 'options': '--multi --bind ctrl-a:select-all --prompt "ATS> "'
\ })))
command! -bang ATV call fzf#run(fzf#wrap(fzf#vim#with_preview({
  \ 'source': argv(),
  \ 'sink*': { lines -> s:open_buffers_in_new_tab(1, lines) },
  \ 'options': '--multi --bind ctrl-a:select-all --prompt "ATV> "'
\ })))

command! Bookmarks call fzf#run(fzf#wrap(fzf#vim#with_preview({
  \ 'source': 'cat .local/bookmarks.txt | sed "/^#\|^$/d"',
  \ 'sink': function('s:gf'),
  \ 'options': '--prompt "Bookmarks> "'
\ })))
" }}}
