" options {{{
set grepprg=grep\ -rnIE\ --exclude-dir=.git\ --exclude-dir=node_modules\ --exclude-dir=..\ $*\ /dev/null
" }}}
"
" command {{{
" skip on vim-tiny
if 1
  command! -nargs=+ -complete=file GR execute 'silent grep! <args>' | redraw! | cw
  command! -nargs=+ -complete=file LGR execute 'silent lgrep! <args>' | redraw! | lw

  fun! s:git_grep(command, arg)
    let tmp1=&grepprg
    set grepprg=git\ grep\ -n\ 2>\ /dev/null
    exe a:command a:arg
    let &grepprg=tmp1
  endf
  command! -nargs=+ -complete=file -bang GGR silent call s:git_grep("grep<bang>", <q-args>) | redraw! | cw
  command! -nargs=+ -complete=file -bang LGGR silent call s:git_grep("lgrep<bang>", <q-args>) | redraw! | lw
  command! -bang Conflicts GGR<bang> '^<<<<<<< HEAD$'
endif
" }}}