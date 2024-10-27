if has('nvim')
  fun! s:update_git_status_cache(cache, jobid, data, event_type)
    let l:value = join(a:data, "\n")
    if l:value != ''
      let a:cache.value = substitute(l:value, '%', '%%', 'g')
      redrawstatus
    endif
  endf
  fun! MyStatusline()
    let l:common = '%=%l,%v %p%% %{&ff} %{&fenc!=""?&fenc:&enc} %y'
    if ! exists('w:git_status_cache')
      let w:git_status_cache = { 'time': 0, 'value': '' }
    endif
    if (reltimefloat(reltime()) - w:git_status_cache.time) > 1
      let l:dir = expand('%:h')
      if isdirectory(l:dir)
        call jobstart('. ${DOT_DIR}/.config/bash/.exports_git_ps1 && __git_ps1 " %s"', {'on_stdout': function('s:update_git_status_cache', [w:git_status_cache]), 'cwd': l:dir})
      else
        let w:git_status_cache.value = ''
      endif
      let w:git_status_cache.time = reltimefloat(reltime())
    endif

    if luaeval('vim.inspect(vim.lsp.buf_get_clients())') == '{}'
      let l:diagnostics_status = ''
    else
      let l:error_cnt = luaeval('#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })')
      let l:warn_cnt = luaeval('#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })')
      let l:info_cnt = luaeval('#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })')
      let l:hint_cnt = luaeval('#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })')
      let l:diagnostics_status = printf('  %d  %d  %d 󰌵 %d', l:error_cnt, l:warn_cnt, l:info_cnt, l:hint_cnt)
    endif

    let l:codeium_status = exists('*codeium#GetStatusString') ? ' %3{codeium#GetStatusString()}' : ''
    let l:autosave_status = get(g:, 'autosave', 0) || get(t:, 'autosave', 0) || get(w:, 'autosave', 0) || get(b:, 'autosave', 0) ? ' 󰓦' : ''

    return ' ' . l:common . w:git_status_cache.value . l:diagnostics_status . l:codeium_status . l:autosave_status . ' '
  endf
  set statusline=%{%MyStatusline()%}
  set winbar=\ %f%m%r%h%w
else
  set statusline=\ %f%m%r%h%w\ %=%l,%v\ %p%%\ 
endif

fun! MyTabline()
  let l:result = ''

  for l:i in range(1, tabpagenr('$'))
    let l:is_sel = l:i == tabpagenr()
    let l:hi = l:is_sel ? '%#TabLineSel#' : '%#TabLine#'
    let l:id = '%' . l:i . 'T'

    let l:buflist = tabpagebuflist(l:i)
    let l:winnr = tabpagewinnr(l:i)
    let l:bufname = bufname(l:buflist->get(l:winnr - 1))
    if l:bufname =~ '://'
      let l:name = printf('[%s]', split(l:bufname, '://')[0])
    else
      let l:fname = fnamemodify(l:bufname, ':t')
      let l:name = len(l:fname) ? l:fname : '[?]'
    endif
    if getbufvar(l:bufname, '&modified')
      let l:flag = '[+]'
    else
      let l:flag = ''
    endif
    let l:label = ' ' . l:name . l:flag . ' '
    let l:result = l:result . l:hi . l:id . l:label
  endfor

  return l:result . '%#TabLineFill#%=' . ' %T'
endf
set tabline=%!MyTabline()
