fun! s:run_on_tmux_pane(command, is_vert)
  if a:is_vert
    let l:sendkey_target = '{right-of}'
    let l:split_layout = '-h'
  else
    let l:sendkey_target = '{down-of}'
    let l:split_layout = '-v'
  endif

  call system(printf('tmux send-keys -t %s "%s" c-m', l:sendkey_target, a:command))
  if v:shell_error
    call system(printf('tmux split-window %s -c "%s" %s -c "%s; tmux select-pane -t !; exec %s"', l:split_layout, getcwd(), $SHELL, a:command, $SHELL))
  endif
endf
command! -nargs=+ TMS call s:run_on_tmux_pane(<q-args>, 0)
command! -nargs=+ TMV call s:run_on_tmux_pane(<q-args>, 1)

let g:tmux_run_is_vert = 1
let g:tmux_run_command = 'make'

command! TMR call s:run_on_tmux_pane(g:tmux_run_command, g:tmux_run_is_vert)
