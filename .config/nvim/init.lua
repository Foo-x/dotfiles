vim.env.XDG_CONFIG_HOME = vim.fn.get(vim.fn.environ(), 'XDG_CONFIG_HOME', vim.env.HOME .. '/.config')
vim.cmd.exe('"source" $XDG_CONFIG_HOME . "/vim/vimrc"')

vim.api.nvim_create_user_command('TrustEdit', 'edit $XDG_STATE_HOME/nvim/trust', {})

local set = vim.keymap.set

require('colorizer').setup({
  filetypes = {
    'css'
  },
})

require('Comment').setup()
-- <C-_> == <C-/>
set('n', '<C-_>', '<Plug>(comment_toggle_linewise_current)')
set('v', '<C-_>', '<Plug>(comment_toggle_linewise_visual)')

local aerial = require('aerial')
aerial.setup({
  keymaps = {
    ['<CR>'] = {
      callback = function()
        aerial.select()
        aerial.close()
      end,
    }
  },
  filter_kind = false,
  on_attach = function()
    set('n', '<M-.>', '<Cmd>AerialToggle<CR>')
  end,
})

require('nvim-autopairs').setup()

require('other-nvim').setup({
  mappings = {
    {
      pattern = 'src/resources/views/(.*).blade.php',
      target = 'src/app/Http/%1.php',
      transformer = 'capitalize_by_slash'
    },
    {
      pattern = 'src/app/Http/(.*).php',
      target = 'src/resources/views/%1.blade.php',
      transformer = 'lowercase'
    },
  },
  transformers = {
    capitalize_by_slash = function(input)
      return input:gsub('^%l', string.upper):gsub('/%l', string.upper)
    end,
    lowercase = function(input)
      return input:lower()
    end
  }
})
set('n', '<leader>oo', ':<C-u>Other<CR>', { silent = true })
set('n', '<leader>ot', ':<C-u>OtherTabNew<CR>', { silent = true })
set('n', '<leader>os', ':<C-u>OtherSplit<CR>', { silent = true })
set('n', '<leader>ov', ':<C-u>OtherVSplit<CR>', { silent = true })
set('n', '<leader>oc', ':<C-u>OtherClear<CR>', { silent = true })

require('stickybuf').setup()

set('n', 'f', '<Plug>(leap-forward-to)')
set('n', 'F', '<Plug>(leap-backward-to)')
set('n', 't', '<Plug>(leap-forward-till)')
set('n', 'T', '<Plug>(leap-backward-till)')

-- lsp {{{
local lspconfig = require('lspconfig')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')
local mason_null_ls = require('mason-null-ls')
local null_ls = require('null-ls')

require('fidget').setup()

mason.setup()
local mason_null_ls_config = {
  'shfmt',
}
if vim.fn.executable('npm') == 1 then
  for _, v in pairs({
    'markdownlint',
    'markuplint',
    'prettier',
    'sql-formatter',
  }) do table.insert(mason_null_ls_config, v) end
end
if vim.fn.executable('tar') == 1 and vim.fn.executable('xz') == 1 then
  for _, v in pairs({
    'shellcheck',
  }) do table.insert(mason_null_ls_config, v) end
end
mason_null_ls.setup({
  ensure_installed = mason_null_ls_config,
})
null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.markdownlint.with({
      extra_args = { '-c', vim.fn.expand('~/.dotfiles/config/.markdownlint.yaml') },
    }),
    null_ls.builtins.formatting.markdownlint.with({
      extra_args = { '-c', vim.fn.expand('~/.dotfiles/config/.markdownlint.yaml') },
    }),
    null_ls.builtins.diagnostics.markuplint,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.code_actions.shellcheck,
    null_ls.builtins.formatting.shfmt.with({
      extra_args = { '-i', '2', '-sr' },
    }),
    null_ls.builtins.formatting.sql_formatter,
  }
})

local mason_lspconfig_config = {
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
    'tsserver',
    'vimls',
    'yamlls',
  }) do table.insert(mason_lspconfig_config, v) end
end
mason_lspconfig.setup({
  ensure_installed = mason_lspconfig_config,
})

mason_lspconfig.setup_handlers({
  function(server)
    local on_attach = function(client, bufnr)
      if client.supports_method('textDocument/documentHighlight') then
        vim.cmd [[
        set updatetime=300
        augroup lsp_document_highlight
          autocmd!
          autocmd CursorHold,CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved,CursorMovedI <buffer> lua vim.lsp.buf.clear_references()
        augroup END
        ]]
      end
      require('ibl').setup({
        indent = {
          char = '▏',
        },
      })
    end

    local opts = {
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
      end,
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }

    lspconfig[server].setup(opts)
  end,
})

require('lsp_signature').setup({
  bind = true,
  handler_opts = {
    border = 'single'
  },
  select_signature_key = '<M-n>',
  move_cursor_key = '<M-x>',
})

local function help()
  local ft = vim.opt.filetype._value
  if ft == 'vim' or ft == 'help' then
    vim.cmd([[execute 'h ' . expand('<cword>') ]])
  else
    vim.lsp.buf.hover()
  end
end

set('n', 'M', help)
set('n', 'gh', vim.diagnostic.open_float)
set('n', '[d', vim.diagnostic.goto_prev)
set('n', ']d', vim.diagnostic.goto_next)
set('n', '<leader>q', vim.diagnostic.setqflist)
set('n', '<leader>l', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    set('n', 'gD', vim.lsp.buf.declaration, opts)
    set('n', 'gd', vim.lsp.buf.definition, opts)
    set('n', 'gi', vim.lsp.buf.implementation, opts)
    set('n', 'gr', vim.lsp.buf.references, opts)
    set('n', 'gt', vim.lsp.buf.type_definition, opts)
    set({ 'n', 'i' }, '<M-m>', vim.lsp.buf.signature_help, opts)
    set('n', '<F2>', vim.lsp.buf.rename, opts)
    set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    set({ 'n', 'v' }, '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, opts)

    vim.diagnostic.config({
      severity_sort = true,
    })
  end,
})

local signs = { Error = " ", Warn = " ", Info = " ", Hint = "󰌵 " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
-- }}}

-- cmp {{{
local cmp = require('cmp')
local lspkind = require('lspkind')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('CmpSetup', {}),
  callback = function()
    if vim.bo.filetype == 'markdown' or vim.b.cmp_loaded then
      return
    end

    cmp.setup.buffer({
      snippet = {
        expand = function(args)
          vim.fn['vsnip#anonymous'](args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-j>'] = cmp.mapping.scroll_docs(4),
        ['<C-k>'] = cmp.mapping.scroll_docs(-4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ['<Tab>'] = cmp.mapping({
          i = function(fallback)
            if vim.fn['vsnip#jumpable'](1) == 1 then
              feedkey('<Plug>(vsnip-jump-next)', '')
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end,
        }),
        ['<S-Tab>'] = cmp.mapping({
          i = function()
            if vim.fn['vsnip#jumpable'](-1) == 1 then
              feedkey('<Plug>(vsnip-jump-prev)', '')
            elseif cmp.visible() then
              cmp.select_prev_item()
            end
          end,
        }),
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
    })
    vim.b.cmp_loaded = true
  end
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  },
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
-- }}}

-- treesitter {{{
if vim.fn.executable('cc') == 1 or vim.fn.executable('gcc') == 1 or vim.fn.executable('clang') == 1 or vim.fn.executable('cl') == 1 or vim.fn.executable('zig') == 1 then
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
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['as'] = { query = '@scope', query_group = 'locals' },
        },
        include_surrounding_whitespace = true,
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          [']f'] = '@function.outer',
          [']s'] = { query = '@scope', query_group = 'locals' },
          [']z'] = { query = '@fold', query_group = 'folds' },
        },
        goto_next_end = {
          [']F'] = '@function.outer',
          [']S'] = { query = '@scope', query_group = 'locals' },
          [']Z'] = { query = '@fold', query_group = 'folds' },
        },
        goto_previous_start = {
          ['[f'] = '@function.outer',
          ['[s'] = { query = '@scope', query_group = 'locals' },
          ['[z'] = { query = '@fold', query_group = 'folds' },
        },
        goto_previous_end = {
          ['[F'] = '@function.outer',
          ['[S'] = { query = '@scope', query_group = 'locals' },
          ['[Z'] = { query = '@fold', query_group = 'folds' },
        },
      },
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    autotag = {
      enable = true,
    },
  })

  set('n', '[c', require('treesitter-context').go_to_context)
end
-- }}}
-- vim: set foldmethod=marker :
