fun! s:everforest()
  packadd! everforest
  color everforest
  let l:palette = everforest#get_palette('medium', {})
  exe 'hi GitGutterAdd guifg=' . l:palette['green'][0]
  exe 'hi GitGutterChange guifg=' . l:palette['blue'][0]
  exe 'hi GitGutterDelete guifg=' . l:palette['red'][0]
  exe 'hi GitGutterChangeDelete guifg=' . l:palette['purple'][0]
  call s:kmd_syntax()
endf
command! Everforest call s:everforest()
fun! s:iceberg()
  packadd! iceberg
  color iceberg
  if has('nvim')
    hi GitGutterAdd guibg=none
    hi GitGutterChange guibg=none
    hi GitGutterDelete guibg=none
    hi GitGutterChangeDelete guibg=none
    hi SignColumn guibg=none
    hi FoldColumn guibg=none
  endif
  call s:kmd_syntax()
endf
command! Iceberg call s:iceberg()

if has('nvim')
  fun! s:base16_grayscale_dark()
    packadd! nvim-base16
    color base16-grayscale-dark
  endf
  command! Base16GrayscaleDark call s:base16_grayscale_dark()
  fun! s:noirbuddy_slate()
    hi clear
    lua << EOF
      require('noirbuddy').setup({
        preset = 'slate',
        colors = {
          diagnostic_error = '#884444',
          diagnostic_warning = '#887744',
          diagnostic_info = '#535353',
          diagnostic_hint = '#535353',
          diff_add = '#6688AA',
          diff_change = '#77AA77',
          diff_delete = '#AA6666',
        }
      })
EOF
    hi DiffText guifg=#f5f5f5 guibg=#336633
    hi GitGutterAdd guifg=#6688AA
    hi GitGutterChange guifg=#77AA77
    hi GitGutterDelete guifg=#AA6666
    hi FoldColumn guibg=bg
    hi Visual guibg=#446688 guifg=white
    hi IncSearch guibg=#554433 guifg=white
    hi Search guibg=#334455 guifg=white
    hi MoreMsg guibg=bg
    hi NormalFloat guibg=#222229
    hi Cursor guibg=#f5f5f5 guifg=#323232
    hi @ibl.indent.char.1 gui=nocombine guifg=#323232
    hi @ibl.whitespace.char.1 gui=nocombine guifg=#323232
    hi @ibl.scope.char.1 gui=nocombine guifg=#737373
    hi @ibl.scope.underline.1 gui=underline guisp=#737373
    hi Comment guifg=#737373
    hi @comment guifg=#737373
    hi NonText guifg=#535353
    hi LineNr guifg=#434343
    hi LspReferenceText guibg=#323232
    hi LspReferenceRead guibg=#323232
    hi LspReferenceWrite guibg=#323232
    hi link CodeiumSuggestion NonText

    lua require('leap').init_highlight(true)
    call s:kmd_syntax()
  endf
  command! NoirbuddySlate call s:noirbuddy_slate()
endif

fun! s:color_complete(...)
  if has('nvim')
    return ['Everforest', 'Iceberg', 'Base16GrayscaleDark', 'NoirbuddySlate']
  endif
  return ['Everforest', 'Iceberg']
endf
command! -nargs=1 -complete=customlist,s:color_complete Color <args>

fun! s:kmd_syntax()
  hi link KmdContext Changed
  hi link KmdTag Added
  hi link KmdDue Removed

  let l:slist = execute('syntax list')
  if l:slist =~ 'KmdContext'
    return
  endif
  windo syntax match KmdContext display " @\S\+"
  windo syntax match KmdTag display " +\S\+"
  windo syntax match KmdDue display " \~\d\{4\}-\d\{2\}-\d\{2\}"
endf

fun! SetupColor()
  try
    if has('nvim')
      NoirbuddySlate
    else
      Iceberg
    endif
  catch
    color desert
    hi SignColumn ctermbg=black
    hi GitGutterAdd ctermfg=green guifg=green
    hi GitGutterChange ctermfg=yellow
    hi GitGutterDelete ctermfg=red
  endtry
endf

augroup SetupColor
  autocmd!
  autocmd VimEnter * call SetupColor()
augroup END
hi netrwMarkFile ctermbg=darkmagenta
