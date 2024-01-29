if ! has('nvim') && ! has('patch-9.0.1499')
  let g:denops_disable_version_check = 1
  finish
endif

imap <C-j> <Plug>(skkeleton-enable)
imap jk <Plug>(skkeleton-enable)
cmap <C-j> <Plug>(skkeleton-enable)
cmap jk <Plug>(skkeleton-enable)

call skkeleton#initialize()

call skkeleton#config({
  \ 'eggLikeNewline': v:true,
  \ 'globalDictionaries': ['~/.skk/SKK-JISYO.L'],
  \ 'keepState': v:true,
  \ 'markerHenkan': '□',
  \ 'markerHenkanSelect': '■',
  \ })

call add(g:skkeleton#mapped_keys, 'df')

call skkeleton#register_kanatable('rom', {
  \ 'jj': 'escape',
  \ 'xn': ['ん'],
  \ })

call skkeleton#register_keymap('input', 'df', 'cancel')
call skkeleton#register_keymap('henkan', 'df', 'cancel')
call skkeleton#register_keymap('input', ';', 'henkanPoint')
