if vim.fn.executable('spzenhan.exe') == 1 then
  vim.api.nvim_create_autocmd('InsertLeave', {
    group = vim.api.nvim_create_augroup('SpzenhanAutoOff', {}),
    callback = function()
      vim.system({ 'spzenhan.exe', '0' }, { text = true }, function(obj)
        vim.b.ime_status = tonumber(obj.stdout)
      end)
    end,
  })
end
