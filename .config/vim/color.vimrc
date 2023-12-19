" skip on vim-tiny
if 1
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
      hi GitGutterAdd guifg=#6688AA
      hi GitGutterChange guifg=#77AA77
      hi GitGutterDelete guifg=#AA6666
      hi FoldColumn guibg=bg
      hi Visual guibg=#446688 guifg=white
      hi IncSearch guibg=#554433 guifg=white
      hi Search guibg=#334455 guifg=white
      hi MoreMsg guibg=bg
      hi NormalFloat guibg=#222229
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

  " only first loading
  if !exists('g:colors_name')
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
  endif
  hi netrwMarkFile ctermbg=darkmagenta
endif
