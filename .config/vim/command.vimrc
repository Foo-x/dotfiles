cnoreabbr w!! w !sudo tee > /dev/null %

" argument list
cnoreabbr AR args
cnoreabbr AD argdelete
cnoreabbr ADA argdelete *
cnoreabbr ADD argdedupe

" skip on vim-tiny
if 1
  command! -nargs=1 -complete=arglist A b <args>
  command! -nargs=* -complete=file -bar AA argadd <args> | argdedupe
  command! TabArgs tabnew | silent! argdo tab next
  command! -nargs=+ -complete=file EditMultiple silent! argdelete * | AA <args> | TabArgs

  fun! s:everforest()
    packadd! everforest
    color everforest
    let l:palette = everforest#get_palette('medium', {})
    exe 'hi GitGutterAdd guifg=' . l:palette['green'][0]
    exe 'hi GitGutterChange guifg=' . l:palette['blue'][0]
    exe 'hi GitGutterDelete guifg=' . l:palette['red'][0]
    exe 'hi GitGutterChangeDelete guifg=' . l:palette['purple'][0]
  endf
  command! Everforest call s:everforest()
  fun! s:aomi_grayscale()
    packadd! vim-aomi-grayscale
    color aomi-grayscale
    hi! link ColorColumn CursorLine
  endf
  command! AomiGrayscale call s:aomi_grayscale()
  fun! s:base16_grayscale_dark()
    packadd! nvim-base16
    color base16-grayscale-dark
  endf
  command! Base16GrayscaleDark call s:base16_grayscale_dark()
  fun! s:iceberg()
    packadd! iceberg
    color iceberg
    hi GitGutterAdd guibg=none
    hi GitGutterChange guibg=none
    hi GitGutterDelete guibg=none
    hi GitGutterChangeDelete guibg=none
    hi SignColumn guibg=none
    hi FoldColumn guibg=none
  endf
  command! Iceberg call s:iceberg()
  if has('nvim')
    fun! s:kanagawa_dragon()
      packadd! kanagawa.nvim
      lua require('kanagawa').setup({
      \  colors = {
      \    theme = {
      \      all = {
      \        ui = {
      \          bg_gutter = "none"
      \        }
      \      }
      \    }
      \  },
      \  overrides = function(colors)
      \    local theme = colors.theme
      \    return {
      \      GitGutterAdd = { fg = theme.vcs.added },
      \      GitGutterChange = { fg = theme.vcs.changed },
      \      GitGutterDelete = { fg = theme.vcs.removed },
      \      GitGutterChangeDelete = { fg = colors.palette.dragonBlue },
      \    }
      \  end,
      \})
      color kanagawa-dragon
    endf
    command! KanagawaDragon call s:kanagawa_dragon()
  endif

  command! TabcloseRight +,$tabdo tabclose

  " insert_print
  if !exists('g:insert_print_prefix')
    let g:insert_print_prefix = '🔴🟠🟡🟢🔵🟣🟤 '
  endif

  if !exists('g:insert_print_suffix')
    let g:insert_print_suffix = ''
  endif

  if !exists('g:insert_print_templates')
    let g:insert_print_templates = {}
    let g:insert_print_templates.python = 'print(f"{}")'
    let g:insert_print_templates.javascript = 'console.log(`{}`);'
    let g:insert_print_templates.typescript = 'console.log(`{}`);'
    let g:insert_print_templates.typescriptreact = 'console.log(`{}`);'
  endif

  if !exists('g:insert_print_text')
    let g:insert_print_text = '$0'
  endif

  fun! s:insert_print()
    let b:insert_print_cur = get(b:, 'insert_print_cur', 0)
    let b:insert_print_cur += 1

    let l:line_template = get(g:insert_print_templates, &filetype, '{}')
    let l:insert_print_line = substitute(l:line_template, '{}', g:insert_print_prefix . b:insert_print_cur . '. ' . g:insert_print_text . g:insert_print_suffix, '')
    put=l:insert_print_line
    norm! ==
    " move cursor to $0 or eol
    if search('$0', '', line('.'))
      norm! "_x"_x
    else
      norm! $
    endif
  endf
  fun! s:init_insert_print()
    if has_key(g:insert_print_templates, &filetype)
      command! -buffer InsertPrint call s:insert_print()
      nnoremap <buffer> <Space>i :<C-u>InsertPrint<CR>
    endif
  endf
  augroup InsertPrint
    autocmd!
    autocmd FileType * call s:init_insert_print()
  augroup END

  fun! SwapWindow(direction)
    if a:direction !~ '[hjkl]'
      return
    endif

    let l:source_winnr = winnr()
    let l:source_bufnr = bufnr()
    let l:source_line = line('.')
    let l:source_col = col('.')

    exe 'winc' a:direction
    let l:target_winnr = winnr()
    if l:target_winnr == l:source_winnr
      return
    endif
    let l:target_bufnr = bufnr()
    let l:target_line = line('.')
    let l:target_col = col('.')

    exe 'b' l:source_bufnr
    call cursor(l:source_line, l:source_col)
    winc p
    exe 'b' l:target_bufnr
    call cursor(l:target_line, l:target_col)
    winc p
  endf
  fun! MoveWindow(direction)
    if a:direction !~ '[hjkl]'
      return
    endif

    let l:source_winnr = winnr()
    let l:source_bufnr = bufnr()
    let l:source_line = line('.')
    let l:source_col = col('.')

    exe 'winc' a:direction
    exe 'b' l:source_bufnr
    call cursor(l:source_line, l:source_col)
    winc p
    b#
    winc p
  endf

  fun! s:autosave()
    if !&modifiable || &readonly || !filewritable(expand('%'))
      return
    endif
    if get(g:, 'autosave', 0) || get(t:, 'autosave', 0) || get(w:, 'autosave', 0) || get(b:, 'autosave', 0)
      silent! update
    endif
  endf
  augroup AutoSave
    autocmd!
    autocmd CursorHold * call s:autosave()
  augroup END
  command! AutoSaveToggleGlobal let g:autosave=!get(g:, 'autosave', 0)
  command! AutoSaveToggleTab let t:autosave=!get(t:, 'autosave', 0)
  command! AutoSaveToggleWindow let w:autosave=!get(w:, 'autosave', 0)
  command! AutoSaveToggleBuffer let b:autosave=!get(b:, 'autosave', 0)
  command! AutoSaveClear let g:autosave=0 | let t:autosave=0 | let w:autosave=0 | let b:autosave=0
  command! AutoSaveInfo echom 'g:' . get(g:, 'autosave', 0) | echom 't:' . get(t:, 'autosave', 0) | echom 'w:' . get(w:, 'autosave', 0) | echom 'b:' . get(b:, 'autosave', 0)

  function! UseEasyRegname()
    if v:event.regname ==# ''
      call setreg(v:event.operator, getreg())
    endif
  endfunction

  augroup UseEasyRegname
    autocmd!
    au TextYankPost * call UseEasyRegname()
  augroup END

  if has('nvim')
    command! SignColumnToggle if &signcolumn =~ '^yes' | set signcolumn=no | else | set signcolumn=yes:2 | endif
    command! VirtualTextToggle lua vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
  else
    command! SignColumnToggle if &signcolumn =~ '^yes' | set signcolumn=no | else | set signcolumn=yes | endif
  endif
endif
