if vim.fn.executable('spzenhan.exe') then
  vim.api.nvim_create_user_command('ImeOn', 'silent !spzenhan.exe 1', {})

  vim.api.nvim_create_autocmd('InsertEnter', {
    group = vim.api.nvim_create_augroup('SpzenhanAutoOn', {}),
    callback = function()
      if vim.b.ime_status == nil then
        vim.b.ime_status = 0
      end
      if vim.b.ime_status == 1 then
        vim.cmd('silent ImeOn')
      end
    end,
  })

  vim.api.nvim_create_autocmd('InsertLeave', {
    group = vim.api.nvim_create_augroup('SpzenhanAutoOff', {}),
    callback = function()
      vim.system({ 'spzenhan.exe', '0' }, { text = true }, function(obj)
        vim.b.ime_status = tonumber(obj.stdout)
      end)
    end,
  })

  vim.api.nvim_create_autocmd('InsertEnter', {
    group = vim.api.nvim_create_augroup('SpzenhanFloatWinSetup', {}),
    callback = function()
      local buf = vim.api.nvim_create_buf(false, true)

      local symbol
      local width
      if vim.b.ime_status == 0 then
        symbol = 'A'
        width = 1
      else
        symbol = 'あ'
        width = 2
      end
      local win = vim.api.nvim_open_win(buf, false, {
        relative = 'cursor',
        width = width,
        height = 1,
        col = 1,
        row = 1,
      })
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { symbol })
      vim.api.nvim_buf_set_option(buf, 'signcolumn', 'no')

      local cur_buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_create_autocmd('CursorMovedI', {
        group = vim.api.nvim_create_augroup('SpzenhanFloatWinUpdate', {}),
        buffer = cur_buf,
        callback = function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, { relative = 'cursor', row = 1, col = 1 })
          end
        end
      })

      vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, false)
        end
      end, 1000)
      vim.api.nvim_create_autocmd('InsertLeave', {
        group = vim.api.nvim_create_augroup('SpzenhanFloatWinClose', {}),
        buffer = cur_buf,
        once = true,
        callback = function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, false)
          end
        end
      })
    end
  })
end
