nmap <Space>j <Plug>(jj)
nnoremap <Plug>(jj) <Nop>

fun! Jv(options = [])
  let l:joined_options = join(a:options, ' ')
  exe '-tabnew jjlog://log\ ' . l:joined_options->escape(' ')
  %d_
  set buftype=nofile
  set filetype=jjlog

  exe 'r !jj log ' . l:joined_options
  1d_
endf
command! JV call Jv()
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

augroup Jujutsu
  autocmd!
  autocmd FileType jj JujutsuDescribeTemplate
  autocmd FileType jjlog nnoremap <buffer><silent> q <Cmd>tabclose<CR>

  if has('nvim')
    autocmd FileType jjlog nnoremap <buffer><silent> u <Cmd>call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> a <Cmd>call JvToggleAll()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> s <Cmd>call JvToggleSummary()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> d <Cmd>call JvToggleDescription()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>aba <Cmd>exe '2TermExecBackground jj abandon <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>d <Cmd>1TermExecTab jj describe <cword><CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>e <Cmd>exe '2TermExecBackground jj edit <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>n<CR> <Cmd>exe '2TermExecBackground jj new <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>na <Cmd>exe '2TermExecBackground jj new --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>nb <Cmd>exe '2TermExecBackground jj new --insert-before <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>nn<CR> <Cmd>exe '2TermExecBackground jj new --no-edit <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>nna <Cmd>exe '2TermExecBackground jj new --no-edit --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>nnb <Cmd>exe '2TermExecBackground jj new --no-edit --insert-before <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rb<CR> <Cmd>exe '2TermExecBackground jj rebase --destination <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rba <Cmd>exe '2TermExecBackground jj rebase --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbb <Cmd>exe '2TermExecBackground jj rebase --insert-befre <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbs<CR> <Cmd>exe '2TermExecBackground jj rebase --source @ --destination <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbsa <Cmd>exe '2TermExecBackground jj rebase --source @ --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbsb <Cmd>exe '2TermExecBackground jj rebase --source @ --insert-before <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbr<CR> <Cmd>exe '2TermExecBackground jj rebase --revisions @ --destination <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbra <Cmd>exe '2TermExecBackground jj rebase --revisions @ --insert-after <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>rbrb <Cmd>exe '2TermExecBackground jj rebase --revisions @ --insert-before <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>sh <Cmd>1TermExecTab jj show <cword><CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>sp<CR> <Cmd>1TermExecTab jj split --revision <cword><CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>spp <Cmd>1TermExecTab jj split --parallel --revision <cword><CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>sq<CR> <Cmd>exe '2TermExecBackground jj squash --into <cword>' \| sleep 100m \| call JvUpdate()<CR>
    autocmd FileType jjlog nnoremap <buffer><silent> <leader>sqi <Cmd>1TermExecTab jj squash --into <cword> --interactive<CR>
  endif

  " autoclose on tableave
  autocmd FileType jjlog autocmd TabLeave <buffer> let g:jjlog_leave = v:true
  autocmd TabEnter * if get(g:, 'jjlog_leave', v:false) && tabpagenr('#') != 0 | exe 'tabclose' tabpagenr('#') | endif | let g:jjlog_leave = v:false
augroup END
