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
  call Jv(split(expand('%'), ' ')[1:])
endf
fun! JvToggleOption(option)
  let l:options = split(expand('%'), ' ')[1:]
  if index(l:options, a:option) == -1
    call add(l:options, a:option)
  else
    call remove(l:options, index(l:options, a:option))
  endif
  call Jv(l:options)
endf
fun! JvDisableOption(option)
  let l:options = split(expand('%'), ' ')[1:]
  if index(l:options, a:option) != -1
    call remove(l:options, index(l:options, a:option))
  endif
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
  call Jov(split(expand('%'), ' ')[2:])
endf
fun! JovToggleOption(option)
  let l:options = split(expand('%'), ' ')[2:]
  if index(l:options, a:option) == -1
    call add(l:options, a:option)
  else
    call remove(l:options, index(l:options, a:option))
  endif
  call Jov(l:options)
endf
fun! JovDisableOption(option)
  let l:options = split(expand('%'), ' ')[2:]
  if index(l:options, a:option) != -1
    call remove(l:options, index(l:options, a:option))
  endif
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

command! JujutsuDescribeTemplate call search('JJ:') | silent ,$d_ | silent exe 'r !jj_desc_template' | 0

if has('nvim')
  command! -nargs=+ Jj 1TermExecTab jj <args>

  " abandon
  command! -nargs=* JjAbandon 2TermExecBackground jj abandon <args>

  " bookmark
  command! -nargs=+ JjBookmarkCreate 2TermExecBackground jj bookmark create <args>
  command! JjBookmarkList 2TermExecVertical jj bookmark list
  command! -nargs=+ JjBookmarkDelete 2TermExecBackground jj bookmark delete <args>
  command! -nargs=+ JjBookmarkForget 2TermExecBackground jj bookmark forget <args>
  command! -nargs=+ JjBookmarkRename 2TermExecBackground jj bookmark rename <args>
  command! -nargs=+ JjBookmarkSet 2TermExecBackground jj bookmark set <args>

  " commit
  command! -nargs=* JjCommit 1TermExecTab jj commit <args>
  command! -nargs=* JjCommitInteractive 1TermExecTab jj commit --interactive <args>
  command! -nargs=+ JjCommitMessage 2TermExecBackground jj commit --message <q-args>
  command! -nargs=+ JjCommitInteractiveMessage 1TermExecTab jj commit --interactive --message <q-args>

  " describe
  command! -nargs=* JjDescribe 1TermExecTab jj describe <args>
  command! -nargs=+ JjDescribeMessage 2TermExecBackground jj describe --message <q-args>

  " diff
  command! -nargs=* JjDiff 1TermExecTab jj diff <args>
  command! -nargs=* JjDiffSummary 2TermExecVertical jj diff --summary <args>
  command! -nargs=* JjDiffStat 2TermExecVertical jj diff --stat <args>
  command! -nargs=* JjDiffGit 1TermExecTab jj diff --git <args>
  command! -nargs=* JjDiffColorWords 1TermExecTab jj diff --color-words <args>
  command! -nargs=* JjDiffParent 1TermExecTab jj diff --revision @- <args>
  command! -nargs=* JjDiffParentSummary 2TermExecVertical jj diff --summary --revision @- <args>
  command! -nargs=* JjDiffParentStat 2TermExecVertical jj diff --stat --revision @- <args>
  command! -nargs=* JjDiffParentGit 1TermExecTab jj diff --git --revision @- <args>
  command! -nargs=* JjDiffParentColorWords 1TermExecTab jj diff --color-words --revision @- <args>

  " diffedit
  command! -nargs=* JjDiffedit 1TermExecTab jj diffedit <args>

  " edit
  command! -nargs=1 JjEdit 2TermExecBackground jj edit <args>

  " git
  command! -nargs=+ JjGit 1TermExecTab jj git <args>
  command! -nargs=* JjGitFetch 2TermExecBackground jj git fetch <args>
  command! -nargs=* JjGitFetchAllRemotes 2TermExecBackground jj git fetch --all-remotes <args>
  command! -nargs=* JjGitPush 2TermExecVertical jj git push <args>
  command! -nargs=* JjGitPushDryRun 2TermExecVertical jj git push --dry-run <args>
  command! -nargs=+ JjGitPushBookmark 2TermExecVertical jj git push --bookmark <args>
  command! -nargs=+ JjGitPushDryRunBookmark 2TermExecVertical jj git push --dry-run --bookmark <args>
  command! -nargs=+ JjGitRemote 2TermExecVertical jj git remote <args>
  command! -nargs=* JjGitRemoteList 2TermExecVertical jj git remote list <args>

  " log
  command! -nargs=* JjLog 1TermExecTab jj log <args>
  command! -nargs=* JjLogDescription 1TermExecTab jj log --template builtin_log_compact_full_description <args>
  command! -nargs=* JjLogGit 1TermExecTab jj log --git <args>
  command! -nargs=* JjLogPatch 1TermExecTab jj log --patch <args>
  command! -nargs=* JjLogSummary 1TermExecTab jj log --summary <args>
  command! -nargs=* JjLogStat 1TermExecTab jj log --stat <args>
  command! -nargs=* JjLogAll 1TermExecTab jj log --revisions :: <args>
  command! -nargs=* JjLogDescriptionAll 1TermExecTab jj log --template builtin_log_compact_full_description --revisions :: <args>
  command! -nargs=* JjLogGitAll 1TermExecTab jj log --git --revisions :: <args>
  command! -nargs=* JjLogPatchAll 1TermExecTab jj log --patch --revisions :: <args>
  command! -nargs=* JjLogSummaryAll 1TermExecTab jj log --summary --revisions :: <args>
  command! -nargs=* JjLogStatAll 1TermExecTab jj log --stat --revisions :: <args>

  " new
  command! -nargs=* JjNew 2TermExecBackground jj new <args>
  command! -nargs=* JjNewMessage 2TermExecBackground jj new --message <q-args>

  " restore
  command! -nargs=* JjRestore 2TermExecBackground jj restore <args>
  command! -nargs=* JjRestoreCurrentFile exe '2TermExecBackground jj restore <args> ' . expand('%')

  " show
  command! -nargs=* JjShow 1TermExecTab jj show <args>
  command! -nargs=* JjShowSummary 2TermExecVertical jj show --summary <args>
  command! -nargs=* JjShowStat 2TermExecVertical jj show --stat <args>
  command! -nargs=* JjShowGit 1TermExecTab jj show --git <args>
  command! -nargs=* JjShowColorWords 1TermExecTab jj show --color-words <args>

  " split
  command! -nargs=* JjSplit 1TermExecTab jj split <args>
  command! -nargs=* JjSplitParallel 1TermExecTab jj split --parallel <args>

  " squash
  command! -nargs=* JjSquash 2TermExecBackground jj squash <args>
  command! -nargs=* JjSquashInteractive 1TermExecTab jj squash --interactive <args>

  " status
  command! -nargs=* JjStatus 2TermExecVertical jj status <args>

  " undo
  command! -nargs=* JjUndo 2TermExecBackground jj undo <args>
endif

augroup Jujutsu
  autocmd!
  autocmd FileType jj JujutsuDescribeTemplate
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
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>na <Cmd>exe '2TermExecBackground jj new --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>nb <Cmd>exe '2TermExecBackground jj new --insert-before <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>nn<CR> <Cmd>exe '2TermExecBackground jj new --no-edit <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>nna <Cmd>exe '2TermExecBackground jj new --no-edit --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>nnb <Cmd>exe '2TermExecBackground jj new --no-edit --insert-before <cword>' \| sleep 100m \| call JvUpdate()<CR>

    "" rebase
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rb<CR> <Cmd>exe '2TermExecBackground jj rebase --destination <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rba <Cmd>exe '2TermExecBackground jj rebase --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbb <Cmd>exe '2TermExecBackground jj rebase --insert-before <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbs<CR> <Cmd>exe '2TermExecBackground jj rebase --source @ --destination <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbsa <Cmd>exe '2TermExecBackground jj rebase --source @ --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbsb <Cmd>exe '2TermExecBackground jj rebase --source @ --insert-before <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbr<CR> <Cmd>exe '2TermExecBackground jj rebase --revisions @ --destination <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbra <Cmd>exe '2TermExecBackground jj rebase --revisions @ --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbrb <Cmd>exe '2TermExecBackground jj rebase --revisions @ --insert-before <cword>' \| sleep 100m \| call JvUpdate()<CR>

    "" show
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>sh <Cmd>2TermExecVertical jj show <cword><CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <CR> <Cmd>2TermExecVertical jj show <cword><CR>

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

    "" diff
    autocmd FileType jjlog command! -nargs=* -buffer JjDiff 1TermExecTab jj diff --revision <cword> <args>
    autocmd FileType jjlog command! -nargs=* -buffer JjDiffSummary 1TermExecTab jj diff --revision <cword> --summary <args>
    autocmd FileType jjlog command! -nargs=* -buffer JjDiffStat 1TermExecTab jj diff --revision <cword> --stat <args>
    autocmd FileType jjlog command! -nargs=* -buffer JjDiffGit 1TermExecTab jj diff --revision <cword> --git <args>
    autocmd FileType jjlog command! -nargs=* -buffer JjDiffColorWords 1TermExecTab jj diff --revision <cword> --color-words <args>

    "" edit
    autocmd FileType jjlog command! -buffer JjEdit exe '2TermExecBackground jj edit <cword>' | sleep 100m | call JvUpdate()

    "" git bookmark set push
    autocmd FileType jjlog command! -nargs=1 JjGitBookmarkSetPush exe '2TermExecVertical jj bookmark set <args> --revision <cword>; jj git push --bookmark <args>'
    autocmd FileType jjlog command! -nargs=1 JjGitBookmarkSetPushDryRun exe '2TermExecVertical jj bookmark set <args> --revision <cword>; jj git push --dry-run --bookmark <args>; jj undo'

    "" new
    autocmd FileType jjlog command! -nargs=* -buffer JjNew exe '2TermExecBackground jj new <cword>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjNewInsertAfter exe '2TermExecBackground jj new --insert-after <cword>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjNewInsertBefore exe '2TermExecBackground jj new --insert-before <cword>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjNewNoEdit exe '2TermExecBackground jj new --no-edit <cword>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjNewNoEditInsertAfter exe '2TermExecBackground jj new --no-edit --insert-after <cword>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjNewNoEditInsertBefore exe '2TermExecBackground jj new --no-edit --insert-before <cword>' | sleep 100m | call JvUpdate()

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

    "" show
    autocmd FileType jjlog command! -nargs=* -buffer JjShow 2TermExecVertical jj show <cword> <args>
    autocmd FileType jjlog command! -nargs=* -buffer JjShowSummary 2TermExecVertical jj show --summary <cword> <args>
    autocmd FileType jjlog command! -nargs=* -buffer JjShowStat 2TermExecVertical jj show --stat <cword> <args>
    autocmd FileType jjlog command! -nargs=* -buffer JjShowGit 2TermExecVertical jj show --git <cword> <args>

    "" split
    autocmd FileType jjlog command! -nargs=* -buffer JjSplit 1TermExecTab jj split --revision <cword> <args>
    autocmd FileType jjlog command! -nargs=* -buffer JjSplitParallel 1TermExecTab jj split --revision <cword> --parallel <args>

    "" squash
    autocmd FileType jjlog command! -nargs=* -buffer JjSquash exe '2TermExecVertical jj squash --into <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjlog command! -nargs=* -buffer JjSquashInteractive 1TermExecTab jj squash --interactive --into <cword> <args>

    " jjoplog
    " keymap
    autocmd FileType jjoplog nnoremap <buffer><silent> <leader>u <Cmd>exe '2TermExecBackground jj undo <cword>' \| sleep 100m \| call JovUpdate()<CR>
    autocmd FileType jjoplog nnoremap <buffer><silent> <leader>s <Cmd>2TermExecVertical jj operation show --patch <cword><CR>
    autocmd FileType jjoplog nnoremap <buffer><silent> <CR> <Cmd>2TermExecVertical jj operation show --patch <cword><CR>

    " command
    autocmd FileType jjoplog command! -nargs=* -buffer JjOperationUndo exe '2TermExecBackground jj undo <cword> <args>' | sleep 100m | call JvUpdate()
    autocmd FileType jjoplog command! -nargs=* -buffer JjOperationShow 2TermExecVertical jj operation show <cword> <args>
    " autoclose on tableave
    autocmd FileType jjlog autocmd TabLeave <buffer> let g:jjlog_leave = v:true
    autocmd TabClosed * let g:jjlog_leave = v:false
    autocmd TabEnter * if get(g:, 'jjlog_leave', v:false) && tabpagenr('#') != 0 | exe 'tabclose' tabpagenr('#') | endif | let g:jjlog_leave = v:false
    autocmd FileType jjoplog autocmd TabLeave <buffer> let g:jjoplog_leave = v:true
    autocmd TabClosed * let g:jjoplog_leave = v:false
    autocmd TabEnter * if get(g:, 'jjoplog_leave', v:false) && tabpagenr('#') != 0 | exe 'tabclose' tabpagenr('#') | endif | let g:jjoplog_leave = v:false
  endif
augroup END
