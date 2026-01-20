local colorizer_opts = {
  filetypes = {
    'css',
  },
}

local function quicker_config()
  local quicker = require('quicker')
  quicker.setup()
end

local function comment_config()
  require('ts_context_commentstring').setup({
    enable_autocmd = false,
  })
  require('Comment').setup({
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
  })
end

local function surround_config()
  require('nvim-surround').setup({
    surrounds = {
      ['k'] = {
        add = { '「', '」' },
        find = function()
          return require('nvim-surround.config').get_selection({
            pattern = '「.-」',
          })
        end,
        delete = '^(.)().-(.)()$',
      },
      ['b'] = {
        add = { '**', '**' },
        find = function()
          local c = vim.pesc('**')
          return require('nvim-surround.config').get_selection({
            pattern = c .. '.-' .. c,
          })
        end,
        delete = '^(..)().-(..)()$',
      },
      ['S'] = {
        add = { '~~', '~~' },
        find = function()
          local c = vim.pesc('~~')
          return require('nvim-surround.config').get_selection({
            pattern = c .. '.-' .. c,
          })
        end,
        delete = '^(..)().-(..)()$',
      },
    },
    aliases = {
      ['b'] = 'b',
    },
  })
end

local various_textobjs_opts = {
  keymaps = {
    useDefaults = true,
  },
}

local function kulala_init()
  vim.filetype.add({
    extension = {
      ['http'] = 'http',
    },
  })
  vim.api.nvim_create_user_command('KulalaScratchpad', function()
    require('kulala').scratchpad()
    vim.bo.buftype = 'nofile'
  end, {})
end

local kulala_opts = {
  default_view = 'headers_body',
  scratchpad_default_contents = {
    '@MY_TOKEN_NAME=my_token_value',
    '',
    '# @name scratchpad_get',
    'GET https://httpbin.org/get HTTP/1.1',
    '',
    '###',
    '',
    '# @name scratchpad_post',
    'POST https://httpbin.org/post HTTP/1.1',
    'accept: application/json',
    'content-type: application/json',
    '',
    '{',
    '  "foo": "bar"',
    '}',
  },
  winbar = true,
  default_winbar_panes = { 'headers_body', 'stats' },
}

local function kulala_config(_, opts)
  require('kulala').setup(opts)

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('Kulala', {}),
    pattern = { 'http' },
    callback = function()
      vim.keymap.set('n', '<CR>', require('kulala').run, { buffer = 0, desc = 'Execute the request' })
      vim.keymap.set('n', '[r', require('kulala').jump_prev, { buffer = 0, desc = 'Jump to the previous request' })
      vim.keymap.set('n', ']r', require('kulala').jump_next, { buffer = 0, desc = 'Jump to the next request' })
      vim.keymap.set('n', '<Space>k', '<Plug>(kulala)', { buffer = 0 })
      vim.keymap.set('n', '<Plug>(kulala)r', require('kulala').replay, { buffer = 0, desc = 'Replay the last run' })
      vim.keymap.set(
        'n',
        '<Plug>(kulala)i',
        require('kulala').inspect,
        { buffer = 0, desc = 'Inspect the current request' }
      )
      vim.keymap.set(
        'n',
        '<Plug>(kulala)y',
        require('kulala').copy,
        { buffer = 0, desc = 'Copy the current request as a curl command' }
      )
      vim.keymap.set(
        'n',
        '<Plug>(kulala)p',
        require('kulala').from_curl,
        { buffer = 0, desc = 'Paste curl from clipboard as http request' }
      )
    end,
  })
end

local oil_opts = {
  skip_confirm_for_simple_edits = true,
  keymaps = {
    ['gd'] = {
      desc = 'Toggle file detail view',
      callback = function()
        Detail = not Detail
        if Detail then
          require('oil').set_columns({ 'permissions', 'size', 'mtime', 'icon' })
        else
          require('oil').set_columns({ 'icon' })
        end
      end,
    },
    ['gy'] = {
      desc = 'Yank full path of the entry under the cursor',
      callback = function()
        require('oil.actions').yank_entry.callback(':p')
        vim.cmd.doautocmd('TextYankPost')
        if vim.v.register == '"' then
          vim.fn['YankToClipboard'](vim.fn.getreg(vim.v.register))
        end
      end,
    },
    ['gY'] = {
      desc = 'Yank full path of all entries',
      callback = function()
        vim.fn.setreg('o', '')
        vim.cmd([[2,$g/^/exe 'norm "Ogy' | let @O="\n"]])
        vim.fn.setreg('"', vim.fn.getreg('o'))
      end,
    },
    ['`'] = false,
    ['~'] = false,
    ['-'] = false,
    ['g\\'] = false,
    ['<C-s>'] = false,
    ['<C-h>'] = false,
    ['<C-t>'] = false,
    ['<'] = 'actions.parent',
    ['>'] = 'actions.select',
    ['<leader>\\'] = { 'actions.select', opts = { vertical = true }, desc = 'Open the entry in a vertical split' },
    ['<leader>_'] = {
      'actions.select',
      opts = { horizontal = true },
      desc = 'Open the entry in a horizontal split',
    },
    ['<leader>o'] = {
      "<Cmd>exe 'silent !open ' . expand('%:p')[6:]<CR>",
      desc = 'Open current directory with the external file explorer',
    },
    ['<leader>t'] = { 'actions.select', opts = { tab = true }, desc = 'Open the entry in new tab' },
  },
  view_options = {
    show_hidden = true,
  },
}

local function oil_config(_, opts)
  require('oil').setup(opts)
  vim.api.nvim_create_autocmd('User', {
    group = vim.api.nvim_create_augroup('OilConfig', {}),
    pattern = 'VeryLazy',
    callback = function()
      vim.api.nvim_create_autocmd('BufWinEnter', {
        group = vim.api.nvim_create_augroup('OilConfig', {}),
        pattern = 'oil://*',
        callback = function()
          if vim.fn.executable('zoxide') == 1 then
            os.execute('zoxide add ' .. string.match(vim.fn.bufname(), 'oil://(.+)/'))
          end
        end,
      })
    end,
  })
end

return {
  {
    'https://github.com/AndrewRadev/linediff.vim',
    cmd = 'Linediff',
  },
  {
    'https://github.com/tyru/capture.vim',
    cmd = 'Capture',
  },
  {
    'https://github.com/mechatroner/rainbow_csv',
    ft = { 'csv', 'tsv', 'csv_semicolon', 'csv_whitespace', 'csv_pipe', 'rfc_csv', 'rfc_semicolon' },
  },
  {
    'https://github.com/NvChad/nvim-colorizer.lua',
    ft = 'css',
    cmd = { 'ColorizerToggle', 'ColorizerAttachToBuffer' },
    opts = colorizer_opts,
  },
  {
    'https://github.com/vim-jp/vimdoc-ja',
    keys = {
      { 'h', 'h', mode = 'c' },
    },
  },
  {
    'https://github.com/tpope/vim-abolish',
    event = 'VeryLazy',
  },
  {
    'https://github.com/kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {
      func_map = {
        ptoggleitem = '',
      },
    },
  },
  {
    'https://github.com/stevearc/quicker.nvim',
    ft = 'qf',
    config = quicker_config,
  },
  {
    'https://github.com/numToStr/Comment.nvim',
    dependencies = {
      'https://github.com/JoosepAlviste/nvim-ts-context-commentstring',
    },
    keys = {
      { '<C-_>', '<Plug>(comment_toggle_linewise_current)' },
      { '<C-_>', '<Plug>(comment_toggle_linewise_visual)', mode = 'v' },
    },
    config = comment_config,
  },
  {
    'https://github.com/kylechui/nvim-surround',
    event = 'VeryLazy',
    config = surround_config,
  },
  {
    'https://github.com/chrisgrieser/nvim-various-textobjs',
    event = 'VeryLazy',
    opts = various_textobjs_opts,
  },
  {
    'https://github.com/mistweaverco/kulala.nvim',
    init = kulala_init,
    ft = 'http',
    opts = kulala_opts,
    config = kulala_config,
  },
  {
    'https://github.com/stevearc/oil.nvim',
    dependencies = { 'https://github.com/nvim-tree/nvim-web-devicons' },
    lazy = false,
    keys = {
      { '<Space>e', '<Cmd>Oil<CR>' },
    },
    opts = oil_opts,
    config = oil_config,
  },
}
