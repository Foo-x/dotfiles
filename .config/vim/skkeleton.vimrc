imap <C-j> <Plug>(skkeleton-enable)
imap jk <Plug>(skkeleton-enable)
cmap <C-j> <Plug>(skkeleton-enable)
cmap jk <Plug>(skkeleton-enable)

call skkeleton#initialize()

call skkeleton#config({
  \ 'globalDictionaries': ['~/.skk/SKK-JISYO.L'],
  \ 'markerHenkan': '□',
  \ 'markerHenkanSelect': '■',
  \ })

call add(g:skkeleton#mapped_keys, 'df')

call skkeleton#register_keymap('input', 'df', 'cancel')
call skkeleton#register_keymap('henkan', 'df', 'cancel')
call skkeleton#register_keymap('henkan', '<CR>', 'kakutei')
