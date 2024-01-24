if has('nvim')
  fun! MyStatusline()
    let l:common = '%=%l,%v %p%% %{&ff} %{&fenc!=""?&fenc:&enc} %y'
    let l:branch = matchstr(FugitiveStatusline(), '\v\[Git\(\zs.+\ze\)\]')
    if l:branch != ''
      let l:branch = ' ' . l:branch
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

    let l:autosave_status = get(g:, 'autosave', 0) || get(t:, 'autosave', 0) || get(w:, 'autosave', 0) || get(b:, 'autosave', 0) ? ' 󰓦' : ''
    let l:pinned_status = v:lua.require("stickybuf").is_pinned() ? ' ' : ''

    return ' ' . l:common . l:branch . l:diagnostics_status . l:autosave_status . l:pinned_status . ' '
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
    let l:label = ' ' . l:name . ' '
    let l:result = l:result . l:hi . l:id . l:label
  endfor

  return l:result . '%#TabLineFill#%=' . ' %T'
endf
set tabline=%!MyTabline()
