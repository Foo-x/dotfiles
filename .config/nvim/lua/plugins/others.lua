local colorizer_opts = {
  filetypes = {
    'css'
  },
}

local function bqf_config()
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('BqfConfig', {}),
    pattern = 'qf',
    callback = function()
      vim.cmd('BqfDisable')
      vim.cmd('BqfEnable')
      vim.keymap.set('n', '<Plug>(quickfix)r', function()
        vim.cmd('BqfDisable')
        vim.cmd('BqfEnable')
      end, { buffer = true })
    end,
  })
end

local various_textobjs_opts = {
  useDefaultKeymaps = true,
}

local function kulala_init()
  vim.filetype.add({
    extension = {
      ['http'] = 'http',
    },
  })
  vim.api.nvim_create_user_command('KulalaScratchpad', function() require('kulala').scratchpad() end, {})
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
    ['g\\'] = false,
    ['<C-s>'] = false,
    ['<C-h>'] = false,
    ['<C-t>'] = false,
    ['<leader>\\'] = { 'actions.select', opts = { vertical = true }, desc = 'Open the entry in a vertical split' },
    ['<leader>_'] = { 'actions.select', opts = { horizontal = true }, desc = 'Open the entry in a horizontal split' },
    ['<leader>t'] = { 'actions.select', opts = { tab = true }, desc = 'Open the entry in new tab' },
  },
  view_options = {
    show_hidden = true,
  },
}

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
    'https://github.com/kevinhwang91/nvim-bqf',
    ft = 'qf',
    config = bqf_config,
  },
  {
    'https://github.com/numToStr/Comment.nvim',
    keys = {
      { '<C-_>', '<Plug>(comment_toggle_linewise_current)' },
      { '<C-_>', '<Plug>(comment_toggle_linewise_visual)', mode = 'v' },
    },
  },
  {
    'https://github.com/kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {}
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
    cmd = 'KulalaScratchpad',
  },
  {
    'https://github.com/stevearc/oil.nvim',
    dependencies = { "https://github.com/nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
      { '<leader>e',     '<Plug>(oil)' },
      { '<Plug>(oil)e',  '<Cmd>Oil<CR>' },
      { '<Plug>(oil)\\', '<Cmd>tabnew<CR><Cmd>Oil<CR><Cmd>vs<CR>' },
    },
    opts = oil_opts,
  }
}
