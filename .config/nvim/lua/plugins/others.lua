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
}
