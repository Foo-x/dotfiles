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
  fun! s:aomi_grayscale()
    packadd! vim-aomi-grayscale
    color aomi-grayscale
    hi! link ColorColumn CursorLine
  endf
  command! AomiGrayscale call s:aomi_grayscale()
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
  endif

  fun! s:color_complete(...)
    if has('nvim')
      return ['Everforest', 'AomiGrayscale', 'Iceberg', 'Base16GrayscaleDark']
    endif
    return ['Everforest', 'AomiGrayscale', 'Iceberg']
  endf
  command! -nargs=1 -complete=customlist,s:color_complete Color <args>

  " only first loading
  if !exists('g:colors_name')
    try
      if has('nvim')
        Base16GrayscaleDark
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
