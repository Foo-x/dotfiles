nnoremap <silent> <Space>e :<C-u>exe 'Fern . -drawer -reveal=% -toggle -width=' . (&columns / 3)<CR>

let g:fern#renderer = "nerdfont"
let g:fern#default_hidden = 1
let g:fern#default_exclude = '\v^%(\.git|node_modules|__pycache__|[Dd]esktop\.ini|Thumbs\.db|\.DS_Store)$|\.pyc$'

if has('nvim')
  fun! s:move()
    lua <<
    vim.cmd [[silent! exe "norm! \<Plug>(fern-action-yank)"]]
    local src = vim.fn.getreg('"')
    local dst = vim.fn.input('New name: ' .. src .. ' -> ', src)
    if dst ~= '' then
      os.execute('mv ' .. src .. ' ' .. dst)
      require('lsp-file-operations.will-rename').callback({ old_name = src, new_name = dst })
      local changed_bufs = vim.fn.getbufinfo({bufmodified = true})
      for _, buf in pairs(changed_bufs) do
        if buf.changed == 1 then
          vim.cmd.tabnew(buf.name)
          vim.cmd.tabprevious()
        end
      end
      vim.cmd [[silent! exe "norm! \<Plug>(fern-action-reload)"]]
    end
.
  endf
else
  fun! s:move()
    silent! exe "norm! \<Plug>(fern-action-yank)"
    let l:src = getreg('"')
    let l:dst = input('New name: ' . l:src . ' -> ', l:src)
    if l:dst != ''
      call system('mv ' . l:src . ' ' . l:dst)
      silent! exe "norm! \<Plug>(fern-action-reload)"
    endif
  endf
endif

fun! s:init_fern()
  nmap <Plug>(fern-close-drawer) <Cmd>FernDo close -drawer -stay<CR>
  nmap <buffer><silent> <Plug>(fern-action-open-and-close) <Plug>(fern-action-open)<Plug>(fern-close-drawer)
  nmap <buffer><expr> <Plug>(fern-my-open-or-expand)
      \ fern#smart#leaf(
      \   "<Plug>(fern-action-open-and-close)",
      \   "<Plug>(fern-action-expand)",
      \ )
  nnoremap <buffer> <CR> <Plug>(fern-my-open-or-expand)
  nnoremap <buffer> i <Nop>
  nnoremap <buffer> K <C-b>
  nnoremap <buffer> in <Plug>(fern-action-new-file)
  nnoremap <buffer> iN <Plug>(fern-action-new-dir)
  nnoremap <buffer> l <Plug>(fern-my-open-or-expand)
  nnoremap <buffer> t <Plug>(fern-action-open:tabedit)gt<Plug>(fern-close-drawer)gT
  nnoremap <buffer> D <Plug>(fern-action-remove=)
  nnoremap <buffer> s <Plug>(fern-action-open:select)<Plug>(fern-close-drawer)
  nnoremap <buffer> m <Cmd>call <SID>move()<CR>
  nnoremap <buffer><silent> x <Plug>(fern-action-yank)<Cmd>call system('open ' . getreg('"'))<CR>
  noremap <buffer> <Tab> <Plug>(fern-action-mark)<Down>
  if maparg('N', 'n') != ''
    nunmap <buffer> N
  endif
endf

augroup Fern
  autocmd! *
  autocmd FileType fern call glyph_palette#apply() | call glyph_palette#defaults#highlight()
  autocmd FileType fern call s:init_fern()
augroup END
