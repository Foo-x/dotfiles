local function fern_init()
  vim.g['fern#renderer'] = 'nerdfont'
  vim.g['fern#default_hidden'] = 1
  vim.g['fern#default_exclude'] =
  '\\v^%(\\.git|node_modules|__pycache__|[Dd]esktop\\.ini|Thumbs\\.db|\\.DS_Store)$|\\.pyc$'
end

local function fern_config()
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('InitFern', {}),
    pattern = { 'fern' },
    callback = function()
      vim.fn['glyph_palette#apply']()
      vim.fn['glyph_palette#defaults#highlight']()
      vim.fn['fern_git_status#init']()

      vim.keymap.set(
        'n',
        '<Plug>(fern-my-open-or-expand)',
        [[fern#smart#leaf('<Plug>(fern-action-open)', '<Plug>(fern-action-expand)')]],
        { buffer = true, remap = true, expr = true, replace_keycodes = false }
      )
      vim.keymap.set('n', '<CR>', '<Plug>(fern-my-open-or-expand)', { buffer = true })
      vim.keymap.set('n', 'i', '<Nop>', { buffer = true })
      vim.keymap.set('n', 'in', '<Plug>(fern-action-new-file)', { buffer = true })
      vim.keymap.set('n', 'iN', '<Plug>(fern-action-new-dir)', { buffer = true })
      vim.keymap.set('n', 'l', '<Plug>(fern-my-open-or-expand)', { buffer = true })
      vim.keymap.set('n', 't', '<Plug>(fern-action-open:tabedit)gt<C-o>gT', { buffer = true })
      vim.keymap.set('n', 'D', '<Plug>(fern-action-remove=)', { buffer = true })
      vim.keymap.set('n', 'm', function()
        vim.cmd([[silent! exe "norm! \<Plug>(fern-action-yank)"]])
        local src = vim.fn.getreg('"')
        local dst = vim.fn.input('New name: ' .. src .. ' -> ', src)
        if dst ~= '' then
          os.execute('mv ' .. src .. ' ' .. dst)
          require('lsp-file-operations.will-rename').callback({ old_name = src, new_name = dst })
          local changed_bufs = vim.fn.getbufinfo({ bufmodified = true })
          for _, buf in pairs(changed_bufs) do
            if buf.changed == 1 then
              vim.cmd.tabnew(buf.name)
              vim.cmd.tabprevious()
            end
          end
          vim.cmd([[silent! exe "norm! \<Plug>(fern-action-reload)"]])
        end
      end, { buffer = true })
      vim.keymap.set(
        'n',
        'x',
        [[<Plug>(fern-action-yank)<Cmd>call system('open ' . getreg('"'))<CR>]],
        { buffer = true, silent = true }
      )
      vim.keymap.set('n', '<Tab>', '<Plug>(fern-action-mark)<Down>', { buffer = true })
      vim.keymap.set('n', 'o', function()
        vim.cmd([[silent! exe "norm! \<Plug>(fern-action-yank)"]])
        local path = vim.fn.getreg('"')
        local stat = vim.loop.fs_stat(path)
        if stat.type == 'directory' then
          vim.cmd('Oil ' .. path)
        else
          vim.cmd('Oil ' .. path:match('^(.*[/])'))
        end
      end, { buffer = true })
      if vim.fn.maparg('N', 'n') == '' then
        vim.keymap.del('n', 'N', { buffer = true })
      end
    end,
  })
end

return {
  {
    'https://github.com/lambdalisue/fern.vim',
    dependencies = {
      'https://github.com/lambdalisue/fern-git-status.vim',
      'https://github.com/lambdalisue/fern-renderer-nerdfont.vim',
      'https://github.com/lambdalisue/glyph-palette.vim',
      'https://github.com/lambdalisue/nerdfont.vim',
    },
    cmd = 'Fern',
    keys = {
      { '<Space>e', ':<C-u>Fern . -reveal=%<CR>', silent = true },
    },
    init = fern_init,
    config = fern_config,
  },
}
