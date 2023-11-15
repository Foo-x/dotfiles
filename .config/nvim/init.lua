vim.env.XDG_CONFIG_HOME = vim.fn.get(vim.fn.environ(), 'XDG_CONFIG_HOME', vim.env.HOME .. '/.config')
vim.cmd.exe('"source" $XDG_CONFIG_HOME . "/vim/vimrc"')

-- lsp
local lspconfig = require('lspconfig')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

require('lspsaga').setup()
require('fidget').setup()

mason.setup()
mason_lspconfig.setup {
  ensure_installed = {
    'tsserver',
    'eslint',
    'lua_ls',
    'vimls',
    'jsonls',
    'yamlls',
  },
}

mason_lspconfig.setup_handlers {
  function(server)
    local opts = {
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }

    lspconfig[server].setup(opts)
  end,
}

vim.api.nvim_create_autocmd({ 'CursorHold' }, {
  pattern = { '*' },
  callback = function()
    require('lspsaga.diagnostic').show_cursor_diagnostics()
  end,
})

local set = vim.keymap.set
set('n', 'gi', vim.lsp.buf.implementation)
set('n', '<F2>', require('lspsaga.rename').rename)
-- TODO: set more keymap

-- cmp
local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup {
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol',
    }),
  },
  experimental = {
    ghost_text = true,
  },
}

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- treesitter
require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'typescript',
    'tsx',
  },
  highlight = {
    enable = true,
  },
})
