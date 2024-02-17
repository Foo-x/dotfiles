vim.env.XDG_CONFIG_HOME = vim.fn.get(vim.fn.environ(), 'XDG_CONFIG_HOME', vim.env.HOME .. '/.config')
vim.cmd.exe('"source" $XDG_CONFIG_HOME . "/vim/vimrc"')

vim.api.nvim_create_user_command('TrustEdit', 'edit $XDG_STATE_HOME/nvim/trust', {})

local set = vim.keymap.set

require("various-textobjs").setup({
  useDefaultKeymaps = true,
})

local toggleterm = require('toggleterm')
toggleterm.setup({
  open_mapping = [[<c-\>]],
  direction = 'tab',
})
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  set('t', '<Esc>', [[<C-\><C-n>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd [[
augroup ToggleTerm
  autocmd!
  autocmd TermOpen term://* lua set_terminal_keymaps()
  autocmd FileType fzf lua vim.keymap.del("t", "<Esc>", { buffer = 0 })
augroup END
]]
local function term_exec_git(cmd)
  toggleterm.exec(cmd, 2, vim.o.columns / 2, nil, 'vertical', 'git')
end
local function term_exec_git_background(cmd)
  toggleterm.exec(cmd, 2, vim.o.columns / 2, nil, 'vertical', 'git', true, false)
end
set('n', '<Plug>(git)<Space>',
  ':2TermExec size=' .. vim.o.columns / 2 .. ' direction=vertical name=git go_back=0 cmd="git "<Left>')
set('n', '<Plug>(git)b', function() term_exec_git('git branch') end)
set('n', '<Plug>(git)ba', function() term_exec_git('git branch -a') end)
set('n', '<Plug>(git)bv', function() term_exec_git('git branch -avv') end)
set('n', '<Plug>(git)s', function() term_exec_git('git status -sb') end)
set('n', '<Plug>(git)f', function() term_exec_git_background('git fetch') end)
set('n', '<Plug>(git)p', function() term_exec_git_background('git pull') end)
set('n', '<Plug>(git)pp', function() term_exec_git_background('git pp') end)
set('n', '<Plug>(git)ps', function() term_exec_git('git push') end)
set('n', '<Plug>(git)sl', function() term_exec_git('git stash list') end)
-- set g:termx<count> and then type <count><Space>x to execute set command
-- i.e. let g:termx1 = 'echo foo' then type 1<Space>x will execute 'echo foo' in terminal
-- if <count> is 1, it can be omitted on typing
set('n', '<Space>x', function()
  local cmd = vim.g['termx' .. vim.v.count1]
  if cmd then
    toggleterm.exec(cmd)
  end
end)

require('nvim-surround').setup()

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

local diffview_actions = require('diffview.actions')
vim.g.diffview_tabpagenr = -1
local diffview_close_augroup = vim.api.nvim_create_augroup('DiffviewClose', {})
vim.api.nvim_create_autocmd('TabEnter', {
  group = diffview_close_augroup,
  callback = function(ev)
    if vim.g.diffview_tabpagenr > 0 then
      vim.cmd.tabclose(vim.g.diffview_tabpagenr)
      vim.g.diffview_tabpagenr = -1
    end
  end,
})
vim.api.nvim_create_autocmd('TabClosed', {
  group = diffview_close_augroup,
  callback = function(ev)
    vim.g.diffview_tabpagenr = -1
  end,
})
if not DiffviewLoaded then
  require('diffview').setup({
    hooks = {
      view_leave = function()
        vim.g.diffview_tabpagenr = vim.fn.tabpagenr()
      end,
    },
    keymaps = {
      view = {
        { 'n', 'q',      '<Cmd>tabclose<CR>',                             { desc = 'Close tab' } },
        { 'n', '<F9>',   '<Cmd>tabclose <bar>GV --all<CR>',               { desc = 'Open the commit log' } },
        { 'n', '<S-F9>', '<Cmd>tabclose <bar>GV --name-status --all<CR>', { desc = 'Open the commit log --name-status' } },
      },
      file_panel = {
        ['L'] = false,
        { 'n', 'M',      diffview_actions.open_commit_log,                                                                                                    { desc = 'Open the commit log panel' } },
        { 'n', 'q',      '<Cmd>tabclose<CR>',                                                                                                                 { desc = 'Close tab' } },
        { 'n', 'cc',     '<Cmd>tabclose <bar> silent !tmux new-window \'git commit; read -n 1 -s -p "press any key to close ..."\'<CR>',                      { desc = 'Commit' } },
        { 'n', 'cC',     '<Cmd>tabclose <bar> silent !tmux new-window \'git commit -n; read -n 1 -s -p "press any key to close ..."\'<CR>',                   { desc = 'Commit' } },
        { 'n', 'ca',     '<Cmd>tabclose <bar> silent !tmux new-window \'git commit --amend; read -n 1 -s -p "press any key to close ..."\'<CR>',              { desc = 'Commit amend' } },
        { 'n', 'cA',     '<Cmd>tabclose <bar> silent !tmux new-window \'git commit --amend -n; read -n 1 -s -p "press any key to close ..."\'<CR>',           { desc = 'Commit amend' } },
        { 'n', 'ce',     '<Cmd>tabclose <bar> silent !tmux new-window \'git commit --amend --no-edit; read -n 1 -s -p "press any key to close ..."\'<CR>',    { desc = 'Commit amend no edit' } },
        { 'n', 'cE',     '<Cmd>tabclose <bar> silent !tmux new-window \'git commit --amend --no-edit -n; read -n 1 -s -p "press any key to close ..."\'<CR>', { desc = 'Commit amend no edit' } },
        { 'n', '<F9>',   '<Cmd>tabclose <bar>GV --all<CR>',                                                                                                   { desc = 'Open the commit log' } },
        { 'n', '<S-F9>', '<Cmd>tabclose <bar>GV --name-status --all<CR>',                                                                                     { desc = 'Open the commit log --name-status' } },
      },
      file_history_panel = {
        ['L'] = false,
        { 'n', 'M', diffview_actions.open_commit_log, { desc = 'Show commit details' } },
        { 'n', 'q', '<Cmd>tabclose<CR>',              { desc = 'Close tab' } },
      },
    },
  })
end
DiffviewLoaded = true

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
      vim.cmd [[
        call SetupColor()
      ]]
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
        ['<CR>'] = function(fallback)
          if not cmp.confirm({ select = false }) then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<c-g>u', true, true, true))
            fallback()
          end
        end,
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

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

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
  enabled = function()
    local result = not vim.regex('^r\\%[ead] \\?!\\|^w\\%[rite] !\\|^w!!\\|^!\\|silent!'):match_str(vim.fn.getcmdline())
    if not result then
      cmp.close()
    end
    return result
  end,
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

-- spzenhan {{{
if vim.fn.executable('spzenhan.exe') then
  vim.api.nvim_create_autocmd('InsertEnter', {
    group = vim.api.nvim_create_augroup('SpzenhanFloatWinSetup', {}),
    callback = function()
      local buf = vim.api.nvim_create_buf(false, true)

      local symbol
      local width
      if vim.b.ime_status == 0 then
        symbol = 'A'
        width = 1
      else
        symbol = 'あ'
        width = 2
      end
      local win = vim.api.nvim_open_win(buf, false, {
        relative = 'cursor',
        width = width,
        height = 1,
        col = 1,
        row = 1,
      })
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { symbol })
      vim.api.nvim_buf_set_option(buf, 'signcolumn', 'no')

      local cur_buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_create_autocmd('CursorMovedI', {
        group = vim.api.nvim_create_augroup('SpzenhanFloatWinUpdate', {}),
        buffer = cur_buf,
        callback = function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, { relative = 'cursor', row = 1, col = 1 })
          end
        end
      })

      vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, false)
        end
      end, 1000)
      vim.api.nvim_create_autocmd('InsertLeave', {
        group = vim.api.nvim_create_augroup('SpzenhanFloatWinClose', {}),
        buffer = cur_buf,
        once = true,
        callback = function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, false)
          end
        end
      })
    end
  })
end
-- }}}

-- vim: set foldmethod=marker :
