local colorizer_opts = {
  filetypes = {
    'css',
  },
}

local function quicker_config()
  local quicker = require('quicker')
  quicker.setup()
  vim.keymap.set('n', '<Plug>(quickfix)r', quicker.refresh)
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
          if vim.fn.executable('zoxide') then
            os.execute('zoxide add ' .. string.match(vim.fn.bufname(), 'oil://(.+)/'))
          end
        end,
      })
    end,
  })
end

local copilot_chat_opts = {
  model = 'claude-3.5-sonnet',
  window = {
    layout = 'float',
    relative = 'cursor',
    width = 1,
    height = 0.4,
    row = 1,
  },
  prompts = {
    Explain = {
      prompt = '> /COPILOT_EXPLAIN\n\n選択されたコードの説明を段落をつけて書いてください。',
    },
    Review = {
      prompt = '> /COPILOT_REVIEW\n\n選択されたコードをレビューしてください。',
    },
    Fix = {
      prompt = '> /COPILOT_GENERATE\n\nこのコードには問題があります。バグを修正したコードに書き換えてください。',
    },
    Optimize = {
      prompt = '> /COPILOT_GENERATE\n\n選択されたコードを最適化し、パフォーマンスと可読性を向上させてください。',
    },
    Docs = {
      prompt = '> /COPILOT_GENERATE\n\n選択されたコードにドキュメンテーションコメントを追加してください。',
    },
    Tests = {
      prompt = '> /COPILOT_GENERATE\n\nコードのテストを生成してください。',
    },
  },
}

local function copilot_chat_config(_, opts)
  local chat = require('CopilotChat')
  chat.setup(opts)

  local copilot_chat_prompts = {}
  for k, _ in pairs(require('CopilotChat.actions').prompt_actions().actions) do
    copilot_chat_prompts[#copilot_chat_prompts + 1] = k
  end
  vim.g.copilot_chat_prompts = copilot_chat_prompts

  vim.keymap.set('n', '<Space>c', '<Plug>(copilot_chat)')
  vim.keymap.set('n', '<Plug>(copilot_chat)c', function()
    local input = vim.fn.input('Quick Chat: ')
    if input ~= '' then
      chat.ask(input, { selection = require('CopilotChat.select').buffer })
    end
  end, { desc = 'Quick Chat' })
  vim.keymap.set('n', '<Plug>(copilot_chat)<Space>', chat.toggle, { desc = 'Toggle Chat' })
  vim.keymap.set(
    'n',
    '<Plug>(copilot_chat)p',
    [[<Cmd>call fzf#run(fzf#wrap({'source': g:copilot_chat_prompts, 'sink': { prompt -> execute('CopilotChat' . prompt) }, 'options': '--prompt "CopilotChat> "'}))<CR>]],
    { desc = 'Select Chat Prompt' }
  )
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
  {
    'https://github.com/CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'https://github.com/github/copilot.lua' },
      { 'https://github.com/nvim-lua/plenary.nvim' },
    },
    event = 'VeryLazy',
    opts = copilot_chat_opts,
    config = copilot_chat_config,
  },
}
