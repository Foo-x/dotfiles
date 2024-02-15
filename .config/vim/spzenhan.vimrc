if !executable('spzenhan.exe')
  finish
endif

command! ImeOff silent !spzenhan.exe 0
command! ImeOn  silent !spzenhan.exe 1

function! ImeAutoOn()
    if !exists('b:ime_status')
        let b:ime_status = 0
    endif
    if b:ime_status == 1
        silent ImeOn
    endif
endfunction

fun! s:set_ime_status(jobid, data, event_type)
    let l:value = substitute(a:data[0], '\r', '', '')
    if l:value != ''
        let b:ime_status = str2nr(l:value)
    endif
endf
function! ImeAutoOff()
    call jobstart('spzenhan.exe 0', {'on_stdout': function('s:set_ime_status')})
endfunction

augroup InsertHook
    autocmd!
    autocmd InsertEnter * call ImeAutoOn()
    autocmd InsertLeave * call ImeAutoOff()
augroup END
