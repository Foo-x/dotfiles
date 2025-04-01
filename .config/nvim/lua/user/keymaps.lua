vim.keymap.set('n', 'gx', function()
  vim.ui.open(vim.fn.expand('<cfile>'))
end, { silent = true })
