local function cmp_init()
  vim.g.vsnip_filetypes = {
    typescript = { 'javascript' },
    typescriptreact = { 'javascript' },
  }
end

local function cmp_config()
  local cmp = require('cmp')
  local lspkind = require('lspkind')

  local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
  end

  local function setup_for_buffer()
    if vim.b.cmp_loaded then
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
        ['<CR>'] = function(fallback)
          if not cmp.confirm({ select = false }) then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<c-g>u', true, true, true))
            fallback()
          end
        end,
        ['<Tab>'] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif vim.fn['vsnip#jumpable'](1) == 1 then
              feedkey('<Plug>(vsnip-jump-next)', '')
            else
              fallback()
            end
          end,
        }),
        ['<S-Tab>'] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn['vsnip#jumpable'](-1) == 1 then
              feedkey('<Plug>(vsnip-jump-prev)', '')
            else
              fallback()
            end
          end,
        }),
      }),
      sources = vim.bo.filetype == 'codecompanion' and cmp.config.sources({
        { name = 'codecompanion_models' },
        { name = 'codecompanion_slash_commands' },
        { name = 'codecompanion_tools' },
        { name = 'codecompanion_variables' },
      }) or cmp.config.sources({
        { name = 'copilot' },
        { name = 'codeium' },
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'buffer' },
        { name = 'path' },
      }),
      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol_text',
          menu = {
            buffer = '[buf]',
            nvim_lsp = '[lsp]',
            path = '[path]',
            vsnip = '[snip]',
          },
          symbol_map = {
            Copilot = '',
            Codeium = '',
          },
        }),
      },
      experimental = {
        ghost_text = true,
      },
    })
    vim.b.cmp_loaded = true
  end

  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = vim.api.nvim_create_augroup('CmpSetup', {}),
    callback = setup_for_buffer,
  })
  setup_for_buffer()

  cmp.event:on(
    'confirm_done',
    require('nvim-autopairs.completion.cmp').on_confirm_done({
      filetypes = {
        codecompanion = false,
      },
    })
  )

  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
    },
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol',
      }),
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
    enabled = function()
      local result = not vim.regex('r\\%[ead] \\?!\\|w\\%[rite] !\\|^w!!\\|^!\\|silent!'):match_str(vim.fn.getcmdline())
      if not result then
        cmp.close()
      end
      return result
    end,
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      { name = 'cmdline' },
    }),
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol_text',
      }),
    },
  })
end

local function codeium_init()
  vim.g.codeium_enabled = true
end

local codeium_opts = {
  virtual_text = {
    filetypes = {
      oil = false,
    },
  },
}

local function codeium_config(_, opts)
  if vim.g.codeium_enabled then
    require('codeium').setup(opts)
  end
end

local copilot_opts = {
  panel = {
    enabled = false,
  },
  suggestion = {
    enabled = false,
  },
  filetypes = {
    oil = false,
  },
  copilot_model = 'gpt-4o-copilot',
}

return {
  {
    'https://github.com/hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      'https://github.com/hrsh7th/cmp-nvim-lsp',
      'https://github.com/hrsh7th/cmp-buffer',
      'https://github.com/hrsh7th/cmp-path',
      'https://github.com/hrsh7th/cmp-cmdline',
      'https://github.com/onsails/lspkind.nvim',
      'https://github.com/hrsh7th/vim-vsnip',
      'https://github.com/hrsh7th/cmp-vsnip',
      'https://github.com/rafamadriz/friendly-snippets',
      { 'https://github.com/windwp/nvim-autopairs', opts = {} },
    },
    init = cmp_init,
    config = cmp_config,
  },
  {
    'https://github.com/Exafunction/codeium.nvim',
    dependencies = {
      'https://github.com/nvim-lua/plenary.nvim',
      'https://github.com/hrsh7th/nvim-cmp',
    },
    event = 'InsertEnter',
    init = codeium_init,
    opts = codeium_opts,
    config = codeium_config,
  },
  {
    'https://github.com/zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    opts = copilot_opts,
  },
  {
    -- there is a issue that it won't suggest on empty line
    -- but if you put space, it will work
    'https://github.com/zbirenbaum/copilot-cmp',
    dependencies = {
      'https://github.com/zbirenbaum/copilot.lua',
    },
    event = 'InsertEnter',
    opts = {},
  },
}
