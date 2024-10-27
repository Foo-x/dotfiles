local DOT_DIR = vim.fn.get(vim.fn.environ(), 'DOT_DIR', vim.env.HOME .. '/.dotfiles')

local function mason_lspconfig_opts()
  local ensure_installed = {
    'lua_ls',
    'marksman',
    'rust_analyzer',
  }
  if vim.fn.executable('npm') == 1 then
    for _, v in pairs({
      'bashls',
      'cssls',
      'cssmodules_ls',
      'dockerls',
      'docker_compose_language_service',
      'eslint',
      'html',
      'intelephense',
      'jsonls',
      'pyright',
      'sqlls',
      'ts_ls',
      'vimls',
      'yamlls',
    }) do table.insert(ensure_installed, v) end
  end
  local handlers = {
    function(server)
      local opts = {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        on_attach = function(client)
          if vim.b.large_buf then
            client.stop()
          end
        end
      }

      if server == 'ts_ls' then
        opts.init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vim.trim(vim.fn.system('npm config get prefix')) ..
                  '/lib/node_modules/@vue/typescript-plugin',
              languages = { "vue" },
            },
          },
        }
        opts.filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
        }
      end

      require('lspconfig')[server].setup(opts)
    end,
  }
  return {
    ensure_installed = ensure_installed,
    handlers = handlers,
  }
end

local function mason_lspconfig_config(_, opts)
  require('mason').setup()
  require('mason-lspconfig').setup(opts)
  vim.keymap.set('n', 'M', function()
    local ft = vim.bo.filetype
    if ft == 'vim' or ft == 'help' then
      vim.cmd([[execute 'h ' . expand('<cword>') ]])
    else
      vim.lsp.buf.hover()
    end
  end)
  vim.keymap.set('n', 'gh', vim.diagnostic.open_float)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setqflist)
  vim.keymap.set('n', '<leader>l', vim.diagnostic.setloclist)

  local function contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  end
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspConfig', {}),
    callback = function(ev)
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = ev.buf })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = ev.buf })
      vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = ev.buf })
      vim.keymap.set({ 'n', 'i' }, '<M-m>', vim.lsp.buf.signature_help, { buffer = ev.buf })
      vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, { buffer = ev.buf })
      vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = ev.buf })
      if contains({
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
          }, vim.bo.filetype) then
        vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
          if vim.fn.exists(':EslintFixAll') == 2 then
            vim.cmd([[EslintFixAll]])
          end
          vim.lsp.buf.format({ async = true, name = 'null-ls' })
        end, { buffer = ev.buf })
      else
        vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
          vim.lsp.buf.format({ async = true })
        end, { buffer = ev.buf })
      end

      vim.diagnostic.config({
        severity_sort = true,
      })

      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client.supports_method('textDocument/documentHighlight') then
        vim.cmd [[
              set updatetime=300
              augroup lsp_document_highlight
                autocmd!
                autocmd CursorHold,CursorHoldI <buffer> silent! lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved,CursorMovedI <buffer> lua vim.lsp.buf.clear_references()
              augroup END
            ]]
      end
      require('ibl').setup({
        indent = {
          char = '▏',
        },
      })
    end,
  })

  local signs = { Error = " ", Warn = " ", Info = " ", Hint = "󰌵 " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  vim.cmd('LspStart')
end

local function mason_null_ls_opts()
  local ensure_installed = {
    'phpcs',
    'php-cs-fixer',
    'shfmt',
  }
  if vim.fn.executable('npm') == 1 then
    for _, v in pairs({
      'blade-formatter',
      'markdownlint',
      'markuplint',
      'prettier',
      'sql-formatter',
    }) do table.insert(ensure_installed, v) end
  end
  if vim.fn.executable('tar') == 1 and vim.fn.executable('xz') == 1 then
    for _, v in pairs({
      'shellcheck',
    }) do table.insert(ensure_installed, v) end
  end
  return {
    ensure_installed = ensure_installed,
  }
end

local function mason_null_ls_config(_, opts)
  require('mason').setup()
  require('mason-null-ls').setup(opts)

  local null_ls = require('null-ls')
  null_ls.setup({
    sources = {
      null_ls.builtins.diagnostics.markdownlint.with({
        extra_args = { '-c', vim.fn.expand(DOT_DIR .. '/config/.markdownlint.yaml') },
        method = null_ls.methods.DIAGNOSTICS_ON_SAVE
      }),
      null_ls.builtins.formatting.markdownlint.with({
        extra_args = { '-c', vim.fn.expand(DOT_DIR .. '/config/.markdownlint.yaml') },
      }),
      null_ls.builtins.formatting.blade_formatter,
      null_ls.builtins.diagnostics.phpcs,
      null_ls.builtins.formatting.phpcsfixer,
      null_ls.builtins.diagnostics.markuplint,
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.shfmt.with({
        extra_args = { '-i', '2', '-sr' },
      }),
      null_ls.builtins.formatting.sql_formatter,
    }
  })
end

local lsp_signature_opts = {
  bind = true,
  handler_opts = {
    border = 'single'
  },
  select_signature_key = '<M-n>',
  move_cursor_key = '<M-x>',
}

return {
  {
    'https://github.com/j-hui/fidget.nvim',
    event = { 'VeryLazy' },
    opts = {},
  },
  {
    'https://github.com/williamboman/mason-lspconfig.nvim',
    event = { 'VeryLazy' },
    dependencies = {
      'https://github.com/neovim/nvim-lspconfig',
      'https://github.com/williamboman/mason.nvim',
      'https://github.com/lukas-reineke/indent-blankline.nvim',
      {
        'https://github.com/antosha417/nvim-lsp-file-operations',
        dependencies = {
          'https://github.com/nvim-lua/plenary.nvim'
        },
        opts = {}
      },
    },
    opts = mason_lspconfig_opts,
    config = mason_lspconfig_config,
  },
  {
    'https://github.com/jay-babu/mason-null-ls.nvim',
    event = { 'VeryLazy' },
    dependencies = {
      'https://github.com/williamboman/mason.nvim',
      {
        'https://github.com/nvimtools/none-ls.nvim',
        dependencies = {
          'https://github.com/nvim-lua/plenary.nvim'
        },
      }
    },
    opts = mason_null_ls_opts,
    config = mason_null_ls_config,
  },
  {
    'https://github.com/ray-x/lsp_signature.nvim',
    event = { 'VeryLazy' },
    opts = lsp_signature_opts,
  },
}
