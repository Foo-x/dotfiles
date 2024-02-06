command! ImeOff silent !spzenhan.exe 0
command! ImeOn  silent !spzenhan.exe 1

function! ImeAutoOn()
    if !exists('b:ime_status')
        let b:ime_status=0
    endif
    if b:ime_status==1
        silent ImeOn
    endif
endfunction

function! ImeAutoOff()
    let b:ime_status=system('spzenhan.exe')
    silent ImeOff
endfunction

augroup InsertHook
    autocmd!
    autocmd InsertEnter * call ImeAutoOn()
    autocmd InsertLeave * call ImeAutoOff()
augroup END
