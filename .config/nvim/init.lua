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
    'bashls',
    'cssls',
    'cssmodules_ls',
    'dockerls',
    'docker_compose_language_service',
    'eslint',
    'intelephense',
    'html',
    'jsonls',
    'lua_ls',
    'marksman',
    'pyright',
    'sqlls',
    'tsserver',
    'vimls',
    'yamlls',
  },
}

mason_lspconfig.setup_handlers {
  function(server)
    local on_attach = function(client, bufnr)
      if client.supports_method "textDocument/documentHighlight" then
        vim.cmd [[
        set updatetime=300
        augroup lsp_document_highlight
          autocmd!
          autocmd CursorHold,CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved,CursorMovedI <buffer> lua vim.lsp.buf.clear_references()
        augroup END
        ]]
      end
    end

    local opts = {
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
      end,
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }

    lspconfig[server].setup(opts)
  end,
}

local function help()
  local ft = vim.opt.filetype._value
  if ft == 'vim' or ft == 'help' then
    vim.cmd([[execute 'h ' . expand('<cword>') ]])
  else
    require('lspsaga.hover').render_hover_doc()
  end
end

local set = vim.keymap.set
set('n', 'K', help)
set('n', 'gi', vim.lsp.buf.implementation)
set('n', '<F2>', require('lspsaga.rename').rename)
-- TODO: set more keymap

-- cmp
local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-j>'] = cmp.mapping.scroll_docs(4),
    ['<C-k>'] = cmp.mapping.scroll_docs(-4),
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
    'bash',
    'css',
    'csv',
    'dockerfile',
    'git_config',
    'gitcommit',
    'gitignore',
    'html',
    'java',
    'javascript',
    'json',
    'jsonc',
    'lua',
    'markdown',
    'markdown_inline',
    'php',
    'python',
    'regex',
    'sql',
    'typescript',
    'tsv',
    'tsx',
    'vim',
  },
  highlight = {
    enable = true,
  },
})
