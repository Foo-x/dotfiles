local DOT_DIR = vim.fn.get(vim.fn.environ(), 'DOT_DIR', vim.env.HOME .. '/.dotfiles')

vim.g.format_on_save = false
vim.api.nvim_create_user_command('FormatOnSaveEnable', function()
  vim.g.format_on_save = true
end, {})
vim.api.nvim_create_user_command('FormatOnSaveDisable', function()
  vim.g.format_on_save = false
end, {})

vim.api.nvim_create_user_command('VirtualTextToggle', function()
  if vim.diagnostic.config().virtual_text then
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.diagnostic.config({ virtual_text = true })
  end
end, {})

local function mason_lspconfig_config(_)
  require('mason').setup()

  vim.lsp.config('lua_ls', {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
        format = {
          enable = false,
        },
      },
    },
  })
  vim.lsp.config('ts_ls', {
    init_options = {
      plugins = {
        {
          name = '@vue/typescript-plugin',
          location = vim.trim(vim.fn.system('npm config get prefix')) .. '/lib/node_modules/@vue/typescript-plugin',
          languages = { 'vue' },
        },
      },
    },
    filetypes = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'vue',
    },
  })

  local ensure_installed = {
    'lua_ls',
    'marksman',
    'rust_analyzer',
    'typos_lsp',
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
    }) do
      table.insert(ensure_installed, v)
    end
  end
  require('mason-lspconfig').setup({
    ensure_installed = ensure_installed,
  })

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

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspConfig', {}),
    callback = function(ev)
      if vim.b.large_buf then
        vim.lsp.buf_detach_client(ev.buf, ev.data.client_id)
        return
      end
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf })
      vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { buffer = ev.buf })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = ev.buf })
      vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = ev.buf })
      vim.keymap.set({ 'n', 'i' }, '<M-m>', vim.lsp.buf.signature_help, { buffer = ev.buf })
      vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, { buffer = ev.buf })
      vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = ev.buf })

      vim.api.nvim_buf_create_user_command(ev.buf, 'CodeAction', function(arg)
        vim.lsp.buf.code_action({
          context = {
            only = { arg.args },
          },
          apply = true,
        })
      end, { nargs = 1 })
      vim.api.nvim_buf_create_user_command(ev.buf, 'CodeActionList', function()
        for _, server in ipairs(vim.lsp.get_clients()) do
          print(server.name)
          local codeActionProvider = server.server_capabilities.codeActionProvider
          print('  ' .. vim.inspect(type(codeActionProvider) == 'table' and codeActionProvider.codeActionKinds or {}))
        end
      end, {})
      vim.api.nvim_buf_create_user_command(ev.buf, 'CodeActionAllCommon', function()
        vim.lsp.buf.code_action({
          context = {
            only = {
              'source.removeUnused',
              'source.addMissingImports',
              'source.organizeImports',
              'source.fixAll',
            },
          },
          apply = true,
        })
      end, {})

      vim.b.has_null_ls = false
      for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == 'null-ls' then
          vim.b.has_null_ls = true
        end
      end
      local function format(async)
        if vim.fn.exists(':EslintFixAll') == 2 then
          vim.cmd([[EslintFixAll]])
        end
        if vim.b.has_null_ls then
          vim.lsp.buf.format({ async = async, name = 'null-ls' })
        else
          vim.lsp.buf.format({ async = async })
        end
      end

      vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
        format(true)
      end, { buffer = ev.buf })

      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('FormatOnSave' .. ev.buf, {}),
        buffer = ev.buf,
        callback = function()
          if vim.g.format_on_save then
            format(false)
          end
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
      })

      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client:supports_method('textDocument/documentHighlight') then
        vim.cmd([[
              set updatetime=300
              augroup lsp_document_highlight
                autocmd!
                autocmd CursorHold,CursorHoldI <buffer> silent! lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved,CursorMovedI <buffer> lua vim.lsp.buf.clear_references()
              augroup END
            ]])
      end
      require('ibl').setup({
        indent = {
          char = '▏',
        },
      })

      KmdSyntax()
    end,
  })

  vim.diagnostic.config({
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = ' ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.INFO] = ' ',
        [vim.diagnostic.severity.HINT] = '󰌵 ',
      },
    },
  })

  vim.cmd('tabdo windo edit')
  if vim.g.save_session then
    vim.cmd('silent! so Session.vim')
  end
end

local function mason_null_ls_opts()
  local ensure_installed = {
    'phpcs',
    'php-cs-fixer',
    'shfmt',
    'stylua',
  }
  if vim.fn.executable('npm') == 1 then
    for _, v in pairs({
      'blade-formatter',
      'markdownlint',
      'markuplint',
      'prettier',
      'sql-formatter',
    }) do
      table.insert(ensure_installed, v)
    end
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
        method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
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
      null_ls.builtins.formatting.stylua,
    },
  })
end

local lsp_signature_opts = {
  bind = true,
  handler_opts = {
    border = 'single',
  },
  select_signature_key = '<M-n>',
  move_cursor_key = '<M-x>',
}

local lean_config = function(_, opts)
  require('lean').setup(opts)
  vim.cmd([[
  augroup Lean
    autocmd!
    autocmd FileType leaninfo nunmap <buffer> J| nnoremap <buffer> J <C-f>
    autocmd FileType leaninfo nunmap <buffer> K| nnoremap <buffer> K <C-b>
  augroup END
  ]])
end

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
          'https://github.com/nvim-lua/plenary.nvim',
        },
        opts = {},
      },
    },
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
          'https://github.com/nvim-lua/plenary.nvim',
        },
      },
    },
    opts = mason_null_ls_opts,
    config = mason_null_ls_config,
  },
  {
    'https://github.com/ray-x/lsp_signature.nvim',
    event = { 'VeryLazy' },
    opts = lsp_signature_opts,
  },
  {
    'https://github.com/Julian/lean.nvim',
    event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
    dependencies = {
      'https://github.com/neovim/nvim-lspconfig',
      'https://github.com/nvim-lua/plenary.nvim',
    },
    opts = {
      mappings = true,
    },
    config = lean_config,
  },
}
