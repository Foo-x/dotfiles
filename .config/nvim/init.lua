vim.env.XDG_CONFIG_HOME = vim.fn.get(vim.fn.environ(), 'XDG_CONFIG_HOME', vim.env.HOME .. '/.config')
vim.cmd.exe('"source" $XDG_CONFIG_HOME . "/vim/vimrc"')

local set = vim.keymap.set

require('symbols-outline').setup()

set('n', '<M-.>', '<Cmd>SymbolsOutline<CR>')

-- lsp
local lspconfig = require('lspconfig')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')
local mason_null_ls = require('mason-null-ls')
local null_ls = require('null-ls')

require('fidget').setup()

mason.setup()
mason_null_ls.setup {
  ensure_installed = {
    'markdownlint',
    'markuplint',
    'prettier',
    'shellcheck',
    'shfmt',
    'sql-formatter',
  },
}
null_ls.setup {
  sources = {
    null_ls.builtins.diagnostics.markdownlint.with {
      extra_args = { '-c', vim.fn.expand('~/.dotfiles/config/.markdownlint.yaml') },
    },
    null_ls.builtins.diagnostics.markuplint,
    null_ls.builtins.formatting.markdownlint.with {
      extra_args = { '-c', vim.fn.expand('~/.dotfiles/config/.markdownlint.yaml') },
    },
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.shfmt.with {
      extra_args = { '-i', '2', '-sr' },
    },
    null_ls.builtins.formatting.sql_formatter,
  }
}
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
    vim.lsp.buf.hover()
  end
end

set('n', 'K', help)
set('n', 'gh', vim.diagnostic.open_float)
set('n', '[d', vim.diagnostic.goto_prev)
set('n', ']d', vim.diagnostic.goto_next)
set('n', '<space>qq', vim.diagnostic.setqflist)
set('n', '<space><space>ll', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    set('n', 'gD', vim.lsp.buf.declaration, opts)
    set('n', 'gd', vim.lsp.buf.definition, opts)
    set('n', 'gi', vim.lsp.buf.implementation, opts)
    set('n', 'gr', vim.lsp.buf.references, opts)
    set('n', 'gt', vim.lsp.buf.type_definition, opts)
    set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    set('n', '<space>rn', vim.lsp.buf.rename, opts)
    set('n', '<F2>', vim.lsp.buf.rename, opts)
    set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    set({ 'n', 'v' }, '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

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

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = {
    ['<Tab>'] = {
      c = function()
        if cmp.visible() then
          cmp.select_next_item()
        else
          cmp.complete()
        end
      end,
    },
    ['<S-Tab>'] = {
      c = function()
        if cmp.visible() then
          cmp.select_prev_item()
        else
          cmp.complete()
        end
      end,
    },
    ['<C-e>'] = {
      c = cmp.mapping.abort(),
    },
  },
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
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
