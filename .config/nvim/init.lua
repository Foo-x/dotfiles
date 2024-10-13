vim.env.XDG_CONFIG_HOME = vim.fn.get(vim.fn.environ(), 'XDG_CONFIG_HOME', vim.env.HOME .. '/.config')
vim.cmd.exe('"source" $XDG_CONFIG_HOME . "/vim/vimrc"')

vim.api.nvim_create_user_command('TrustEdit', 'edit $XDG_STATE_HOME/nvim/trust', {})

local set = vim.keymap.set

require('lsp-file-operations').setup()

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

-- Codeium
vim.g.codeium_enabled = true
if vim.g.codeium_enabled then
  vim.g.codeium_disable_bindings = 1
  set('i', "<M-'>", function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
  set('i', '<M-[>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
  set('i', '<M-]>', function() return vim.fn['codeium#CycleOrComplete']() end, { expr = true, silent = true })
  set('i', '<C-]>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd [[
augroup ToggleTerm
  autocmd!
  autocmd TermOpen term://* lua set_terminal_keymaps()
  autocmd FileType fzf lua vim.keymap.del("t", "<Esc>", { buffer = 0 })
augroup END
]]
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('ToggleTerm', { clear = false }),
  callback = function()
    if vim.bo.filetype ~= 'gitcommit' then
      toggleterm.exec('', 2, vim.o.columns / 2, nil, 'vertical', 'git', false)
      set_terminal_keymaps()
      vim.cmd('ToggleTerm')
      toggleterm.exec('', 1, nil, nil, 'tab', nil, false)
      set_terminal_keymaps()
      vim.cmd('ToggleTerm')
    end
  end,
})
local function term_exec_git(cmd)
  toggleterm.exec('git ' .. cmd, 2, vim.o.columns / 2, nil, 'vertical', 'git')
end
local function term_exec_git_background(cmd)
  toggleterm.exec('git ' .. cmd, 2, vim.o.columns / 2, nil, 'vertical', 'git', true, false)
end
set('n', '<Plug>(git)<Space>',
  ':2TermExec size=' .. vim.o.columns / 2 .. ' direction=vertical name=git go_back=0 cmd="git "<Left>')
set('n', '<Plug>(git)b', function() term_exec_git('branch') end)
set('n', '<Plug>(git)ba', function() term_exec_git('branch -a') end)
set('n', '<Plug>(git)bv', function() term_exec_git('branch -avv') end)
set('n', '<Plug>(git)s', function() term_exec_git('status -sb') end)
set('n', '<Plug>(git)f', function() term_exec_git_background('fetch') end)
set('n', '<Plug>(git)p', function() term_exec_git_background('pull') end)
set('n', '<Plug>(git)pp', function() term_exec_git_background('pp') end)
set('n', '<Plug>(git)ps', function() term_exec_git('push') end)
set('n', '<Plug>(git)sl', function() term_exec_git('stash list') end)
-- set g:termx<count> and then type <count><Space>x to execute set command
-- i.e. let g:termx1 = 'echo foo' then type 1<Space>x will execute 'echo foo' in terminal
-- if <count> is 1, it can be omitted on typing
set('n', '<Space>x', function()
  local cmd = vim.g['termx' .. vim.v.count1]
  if cmd then
    toggleterm.exec(cmd)
  end
end)
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('GVLua', {}),
  pattern = { "GV" },
  callback = function()
    set('n', 'cf', function()
      local sha = vim.fn.expand('<cword>')
      return [[<Cmd>silent !tmux new-window 'git commit --fixup ]] ..
          sha .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
    end, { buffer = 0, expr = true })
    set('n', 'cF', function()
      local sha = vim.fn.expand('<cword>')
      return [[<Cmd>silent !tmux new-window 'git commit --fixup ]] ..
          sha ..
          [[ && git -c sequence.editor=true rebase -i --autosquash ]] ..
          sha .. [[^; read -n 1 -s -p "press any key to close ..."'<CR>]]
    end, { buffer = 0, expr = true })
    set('n', 'ca', function()
      local sha = vim.fn.expand('<cword>')
      return [[<Cmd>silent !tmux new-window 'git commit --fixup amend:]] ..
          sha .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
    end, { buffer = 0, expr = true })
    set('n', 'cA', function()
      local sha = vim.fn.expand('<cword>')
      return [[<Cmd>silent !tmux new-window 'git commit --fixup amend:]] ..
          sha ..
          [[ && git -c sequence.editor=true rebase -i --autosquash ]] ..
          sha .. [[^; read -n 1 -s -p "press any key to close ..."'<CR>]]
    end, { buffer = 0, expr = true })
    set('n', 'cr', function()
      local sha = vim.fn.expand('<cword>')
      return [[<Cmd>silent !tmux new-window 'git commit --fixup reword:]] ..
          sha .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
    end, { buffer = 0, expr = true })
    set('n', 'cR', function()
      local sha = vim.fn.expand('<cword>')
      return [[<Cmd>silent !tmux new-window 'git commit --fixup reword:]] ..
          sha ..
          [[ && git -c sequence.editor=true rebase -i --autosquash ]] ..
          sha .. [[^; read -n 1 -s -p "press any key to close ..."'<CR>]]
    end, { buffer = 0, expr = true })
    set('n', 'cs', function()
      local sha = vim.fn.expand('<cword>')
      return [[<Cmd>silent !tmux new-window 'git commit --squash ]] ..
          sha .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
    end, { buffer = 0, expr = true })
    set('n', 'cS', function()
      local sha = vim.fn.expand('<cword>')
      return [[<Cmd>silent !tmux new-window 'git commit --squash ]] ..
          sha .. [[ && git rebase -i --autosquash ]] .. sha .. [[^; read -n 1 -s -p "press any key to close ..."'<CR>]]
    end, { buffer = 0, expr = true })
    set('n', 'me', function()
      local sha = vim.fn.expand('<cword>')
      return [[<Cmd>silent !tmux new-window 'git merge ]] ..
          sha .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
    end, { buffer = 0, expr = true })
  end,
})

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
      return input:gsub('^%l', string.upper):gsub('/%l', string.upper):gsub('-%l', function(s)
        return s:sub(2, 2):upper()
      end)
    end,
    lowercase = function(input)
      return input:gsub('^%u', string.lower):gsub('/%u', string.lower):gsub('%u', function(s)
        return '-' .. s:lower()
      end)
    end
  },
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
        { 'n', 'q',          '<Cmd>tabclose<CR>',                             { desc = 'Close tab' } },
        { 'n', '<F9>',       '<Cmd>tabclose <bar>GV --all<CR>',               { desc = 'Open the commit log' } },
        { 'n', '<S-F9>',     '<Cmd>tabclose <bar>GV --name-status --all<CR>', { desc = 'Open the commit log --name-status' } },
        { 'n', '<leader>s',  diffview_actions.toggle_stage_entry,             { desc = 'Stage / unstage the selected entry' } },
        { 'n', '<leader>cx', diffview_actions.conflict_choose('all'),         { desc = 'Choose all the versions of a conflict' } },
        { 'n', '<leader>cX', diffview_actions.conflict_choose_all('all'),     { desc = 'Choose all the versions of a conflict for the whole file' } },
        ['<leader>ca'] = false,
        ['<leader>cA'] = false,
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
        { 'n', 't',      diffview_actions.goto_file_tab,                                                                                                      { desc = 'Open the file in a new tabpage' } },
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
local null_ls_sources = {
  null_ls.builtins.diagnostics.markdownlint.with({
    extra_args = { '-c', vim.fn.expand('~/.dotfiles/config/.markdownlint.yaml') },
    method = null_ls.methods.DIAGNOSTICS_ON_SAVE
  }),
  null_ls.builtins.formatting.markdownlint.with({
    extra_args = { '-c', vim.fn.expand('~/.dotfiles/config/.markdownlint.yaml') },
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
null_ls.setup({
  sources = null_ls_sources
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
    'ts_ls',
    'vimls',
    'yamlls',
  }) do table.insert(mason_lspconfig_config, v) end
end
mason_lspconfig.setup({
  ensure_installed = mason_lspconfig_config,
})

mason_lspconfig.setup_handlers({
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
            location = vim.trim(vim.fn.system('npm config get prefix')) .. '/lib/node_modules/@vue/typescript-plugin',
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
    local opts = { buffer = ev.buf }
    set('n', 'gD', vim.lsp.buf.declaration, opts)
    set('n', 'gd', vim.lsp.buf.definition, opts)
    set('n', 'gi', vim.lsp.buf.implementation, opts)
    set('n', 'gr', vim.lsp.buf.references, opts)
    set('n', 'gt', vim.lsp.buf.type_definition, opts)
    set({ 'n', 'i' }, '<M-m>', vim.lsp.buf.signature_help, opts)
    set('n', '<F2>', vim.lsp.buf.rename, opts)
    set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    if contains({
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
        }, vim.bo.filetype) then
      set({ 'n', 'v' }, '<leader>f', function()
        if vim.fn.exists(':EslintFixAll') == 2 then
          vim.cmd([[EslintFixAll]])
        end
        vim.lsp.buf.format({ async = true, name = 'null-ls' })
      end, opts)
    else
      set({ 'n', 'v' }, '<leader>f', function()
        vim.lsp.buf.format({ async = true })
      end, opts)
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
    vim.cmd [[
        call SetupColor()
      ]]
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
            if cmp.visible() then
              cmp.select_next_item()
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
          i = function()
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn['vsnip#jumpable'](-1) == 1 then
              feedkey('<Plug>(vsnip-jump-prev)', '')
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
    local result = not vim.regex('r\\%[ead] \\?!\\|w\\%[rite] !\\|^w!!\\|^!\\|silent!'):match_str(vim.fn
      .getcmdline())
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
      disable = function(_, buf)
        vim.b.large_buf = false

        -- check size
        local max_filesize = 100 * 1024 -- 100 KB
        local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
        if size > max_filesize then
          vim.b.large_buf = true
          return true
        end

        -- check column lengths
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for _, line in ipairs(lines) do
          if #line > vim.o.synmaxcol then
            vim.b.large_buf = true
            return true
          end
        end

        vim.o.foldmethod = 'expr'
      end,
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
