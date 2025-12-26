vim.keymap.set('n', 'gx', function()
  vim.ui.open(vim.fn.expand('<cfile>'))
end, { silent = true })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'man',
  callback = function(ev)
    vim.keymap.set('n', 'gO', "<Cmd>lua require'man'.show_toc()<CR>", { buffer = ev.buf, silent = true })
    vim.keymap.set('n', '<CR>', '<C-]>', { buffer = ev.buf, silent = true })
  end,
})
