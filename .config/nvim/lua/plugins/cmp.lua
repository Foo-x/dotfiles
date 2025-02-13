local function cmp_config()
  local cmp = require('cmp')
  local lspkind = require('lspkind')

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
  end

  local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
  end

  local function setup_for_buffer()
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
            elseif has_words_before() then
              cmp.complete()
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
            end
          end,
        }),
      }),
      sources = cmp.config.sources({
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

  vim.api.nvim_create_autocmd({ 'BufNew' }, {
    group = vim.api.nvim_create_augroup('CmpSetup', {}),
    callback = setup_for_buffer,
  })
  setup_for_buffer()

  cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())

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
    opts = {},
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
