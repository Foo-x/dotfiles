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

  " only first loading
  if !exists('g:colors_name')
    try
      Base16GrayscaleDark
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
