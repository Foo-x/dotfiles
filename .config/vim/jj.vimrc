nmap <Space>j <Plug>(jj)
nnoremap <Plug>(jj) <Nop>
nnoremap <Plug>(jj)l <Cmd>JV<CR>
nnoremap <Plug>(jj). <Cmd>JV!<CR>
nnoremap <Plug>(jj)o <Cmd>JOV<CR>

fun! Jv(options = [], file = '')
  let l:joined_options = join(a:options, ' ')
  exe 'tabnew jjlog://log\ ' . l:joined_options->escape(' ') . '\ ' . a:file
  %d_
  set buftype=nofile
  set filetype=jjlog

  exe 'r !jj log ' . l:joined_options . ' ' a:file
  1d_
endf
command! -bang JV if <bang>0 | call Jv([], expand('%')) | else | call Jv([], '') | endif
cnoreabbr jv JV

fun! JvUpdate()
  let l:options = split(expand('%'), ' ')[1:]
  quit
  call Jv(l:options)
endf
fun! JvToggleOption(option)
  let l:options = split(expand('%'), ' ')[1:]
  if index(l:options, a:option) == -1
    call add(l:options, a:option)
  else
    call remove(l:options, index(l:options, a:option))
  endif
  quit
  call Jv(l:options)
endf
fun! JvDisableOption(option)
  let l:options = split(expand('%'), ' ')[1:]
  if index(l:options, a:option) != -1
    call remove(l:options, index(l:options, a:option))
  endif
  quit
  call Jv(l:options)
endf
fun! JvToggleAll()
  call JvToggleOption('--revisions=::')
endf
fun! JvToggleSummary()
  call JvDisableOption('--stat')
  call JvToggleOption('--summary')
endf
fun! JvToggleStat()
  call JvDisableOption('--summary')
  call JvToggleOption('--stat')
endf
fun! JvToggleDescription()
  call JvToggleOption('--template=builtin_log_compact_full_description')
endf

fun! Jov(options = [])
  let l:joined_options = join(a:options, ' ')
  exe 'tabnew jjoplog://operation\ log\ ' . l:joined_options->escape(' ')
  %d_
  set buftype=nofile
  set filetype=jjoplog

  exe 'r !jj operation log ' . l:joined_options
  1d_
endf
command! JOV call Jov()
cnoreabbr jov JOV

fun! JovUpdate()
  let l:options = split(expand('%'), ' ')[2:]
  quit
  call Jov(l:options)
endf
fun! JovToggleOption(option)
  let l:options = split(expand('%'), ' ')[2:]
  if index(l:options, a:option) == -1
    call add(l:options, a:option)
  else
    call remove(l:options, index(l:options, a:option))
  endif
  quit
  call Jov(l:options)
endf
fun! JovDisableOption(option)
  let l:options = split(expand('%'), ' ')[2:]
  if index(l:options, a:option) != -1
    call remove(l:options, index(l:options, a:option))
  endif
  quit
  call Jov(l:options)
endf
fun! JovToggleSummary()
  call JovDisableOption('--stat')
  call JovToggleOption('--summary')
endf
fun! JovToggleStat()
  call JovDisableOption('--summary')
  call JovToggleOption('--stat')
endf

fun! s:jujutsu_describe_template()
  call search('JJ: ChangeId: \zs')
  let l:change_id = strpart(getline('.'), col('.') - 1)
  call search('JJ:')
  silent ,$d_
  silent exe 'r !jj_desc_template ' . l:change_id
  0
endf
command! JujutsuDescribeTemplate call s:jujutsu_describe_template()

augroup Jujutsu
  autocmd!
  autocmd FileType jj,jjdescription JujutsuDescribeTemplate
  autocmd FileType jjlog nnoremap <buffer><silent> q <Cmd>tabclose<CR>
  autocmd FileType jjlog nnoremap <buffer><silent> u <Cmd>call JvUpdate()<CR>
  autocmd FileType jjlog nnoremap <buffer><silent> a <Cmd>call JvToggleAll()<CR>
  autocmd FileType jjlog nnoremap <buffer><silent> su <Cmd>call JvToggleSummary()<CR>
  autocmd FileType jjlog nnoremap <buffer><silent> st <Cmd>call JvToggleStat()<CR>
  autocmd FileType jjlog nnoremap <buffer><silent> d <Cmd>call JvToggleDescription()<CR>
  autocmd FileType jjlog nnoremap <buffer><silent> g? <Cmd>nmap <buffer><CR>

  autocmd FileType jjoplog nnoremap <buffer><silent> q <Cmd>tabclose<CR>
  autocmd FileType jjoplog nnoremap <buffer><silent> u <Cmd>call JovUpdate()()<CR>
  autocmd FileType jjoplog nnoremap <buffer><silent> su <Cmd>call JovToggleSummary()<CR>
  autocmd FileType jjoplog nnoremap <buffer><silent> st <Cmd>call JovToggleStat()<CR>
  autocmd FileType jjoplog nnoremap <buffer><silent> g? <Cmd>nmap <buffer><CR>

  if has('nvim')
    " jjlog
    " keymap
    "" describe
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>d <Cmd>1TermExecTab jj describe <cword><CR>

    "" edit
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>e <Cmd>exe '2TermExecBackground jj edit <cword>' \| sleep 100m \| call JvUpdate()<CR>

    "" new
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>n<CR> <Cmd>exe '2TermExecBackground jj new <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>N<CR> <Cmd>exe '2TermExecBackground jj N <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>na <Cmd>exe '2TermExecBackground jj new --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>nb <Cmd>exe '2TermExecBackground jj new --insert-before <cword>' \| sleep 100m \| call JvUpdate()<CR>

    "" show
    autocmd FileType jjlog nnoremap <buffer><silent> <CR> <Cmd>exe 'DiffviewOpen ' .. matchstr(getline('.'), '\v\S+$') .. '^!'<CR>

    "" split
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>sp<CR> <Cmd>1TermExecTab jj split --revision <cword><CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>spp <Cmd>1TermExecTab jj split --parallel --revision <cword><CR>

    "" squash
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>sq<CR> <Cmd>exe '2TermExecBackground jj squash --into <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>sqi <Cmd>1TermExecTab jj squash --into <cword> --interactive<CR>

    " command
    "" abandon
    autocmd FileType jjlog command! -nargs=* -buffer JjAbandon exe '2TermExecBackground jj abandon <cword> <args>' | sleep 100m | call JvUpdate()

    "" bookmark
    autocmd FileType jjlog command! -nargs=+ -buffer JjBookmarkSet 2TermExecBackground jj bookmark set --revision <cword> <args>

    "" describe
    autocmd FileType jjlog command! -nargs=* -buffer JjDescribe 1TermExecTab jj describe <cword> <args>
    autocmd FileType jjlog command! -nargs=+ -buffer JjDescribeMessage 2TermExecVertical jj describe <cword> --message <q-args>

    "" git bookmark set push
    fun! s:jgpb(bookmark = '')
      if a:bookmark == ''
        let l:bookmark = trim(system('git db'))
      else
        let l:bookmark = a:bookmark
      endif
      exe '2TermExecVertical jj bookmark set ' . l:bookmark . ' --revision <cword>; jj git push --bookmark ' . l:bookmark
    endf
    autocmd FileType jjlog command! -nargs=? JjGitPushBookmarkSet call s:jgpb(<q-args>)
    fun! s:jgpnb(bookmark = '')
      if a:bookmark == ''
        let l:bookmark = trim(system('git db'))
      else
        let l:bookmark = a:bookmark
      endif
      exe '2TermExecVertical jj bookmark set ' . l:bookmark . ' --revision <cword>; jj git push --dry-run --bookmark ' . l:bookmark . '; jj undo'
    endf
    autocmd FileType jjlog command! -nargs=? JjGitPushDryRunBookmarkSet call s:jgpnb(<q-args>)
    cnoreabbr jgpb JjGitPushBookmarkSet
    cnoreabbr jgpnb JjGitPushDryRunBookmarkSet

    "" rebase
    autocmd FileType jjlog command! -nargs=* -buffer JjRebase exe '2TermExecBackground jj rebase --destination <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjRebaseInsertAfter exe '2TermExecBackground jj rebase --insert-after <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjRebaseInsertBefore exe '2TermExecBackground jj rebase --insert-before <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjRebaseSource exe '2TermExecBackground jj rebase --source @ --destination <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjRebaseSourceInsertAfter exe '2TermExecBackground jj rebase --source @ --insert-after <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjRebaseSourceInsertBefore exe '2TermExecBackground jj rebase --source @ --insert-before <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjRebaseRevision exe '2TermExecBackground jj rebase --revisions @ --destination <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjRebaseRevisionInsertAfter exe '2TermExecBackground jj rebase --revisions @ --insert-after <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjRebaseRevisionInsertBefore exe '2TermExecBackground jj rebase --revisions @ --insert-before <cword> <args>' | sleep 100m | call JvUpdate()

    "" squash
    autocmd FileType jjlog command! -nargs=* -buffer JjSquash exe '2TermExecVertical jj squash --into <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjSquashInteractive 1TermExecTab jj squash --interactive --into <cword> <args>

    " jjoplog
    " keymap
    autocmd FileType jjoplog nnoremap <buffer><silent> <leader>u <Cmd>exe '2TermExecBackground jj undo <cword>' \| sleep 100m \| call JovUpdate()<CR>
    autocmd FileType jjoplog nnoremap <buffer><silent> <leader>rs <Cmd>exe '2TermExecBackground jj operation restore <cword>' \| sleep 100m \| call JovUpdate()<CR>
    autocmd FileType jjoplog nnoremap <buffer><silent> <leader>rv <Cmd>exe '2TermExecBackground jj operation revert <cword>' \| sleep 100m \| call JovUpdate()<CR>
    autocmd FileType jjoplog nnoremap <buffer><silent> <CR> <Cmd>2TermExecVertical jj operation show --patch <cword><CR>
  endif
augroup END
