local function gitgutter_init()
  vim.g.gitgutter_set_sign_backgrounds = 1
  vim.g.gitgutter_preview_win_floating = 0
  vim.g.gitgutter_sign_priority = 20
end

local function gitgutter_config()
  vim.cmd('GitGutterLineNrHighlightsEnable')
  vim.keymap.set('n', '<Plug>(git)', '<Plug>(GitGutterPreviewHunk)<C-w>P')
  vim.keymap.set('n', '<C-j>', '<Plug>(GitGutterNextHunk)')
  vim.keymap.set('n', '<C-k>', '<Plug>(GitGutterPrevHunk)')
end

local function gv_config()
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('GVLua', {}),
    pattern = { 'GV' },
    callback = function(_)
      vim.keymap.set('n', '<CR>', function()
        local key = vim.api.nvim_replace_termcodes('.<C-u>DiffviewOpen<C-e>^!<CR>', true, false, true)
        vim.api.nvim_feedkeys(key, '', false)
      end, { buffer = 0, expr = true, silent = true })
      vim.keymap.set('n', 'rb<CR>', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git rebase ]]
          .. sha
          .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'rbi', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git rebase -i ]]
          .. sha
          .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'chp', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git cherry-pick ]]
          .. sha
          .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'cf', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git commit --fixup ]]
          .. sha
          .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'cF', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git commit --fixup ]]
          .. sha
          .. [[ && git -c sequence.editor=true rebase -i --autosquash ]]
          .. sha
          .. [[^; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'ca', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git commit --fixup amend:]]
          .. sha
          .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'cA', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git commit --fixup amend:]]
          .. sha
          .. [[ && git -c sequence.editor=true rebase -i --autosquash ]]
          .. sha
          .. [[^; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'cr', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git commit --fixup reword:]]
          .. sha
          .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'cR', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git commit --fixup reword:]]
          .. sha
          .. [[ && git -c sequence.editor=true rebase -i --autosquash ]]
          .. sha
          .. [[^; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'cs', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git commit --squash ]]
          .. sha
          .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'cS', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git commit --squash ]]
          .. sha
          .. [[ && git rebase -i --autosquash ]]
          .. sha
          .. [[^; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'me', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git merge ]]
          .. sha
          .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
      vim.keymap.set('n', 'bi', function()
        local sha = vim.fn.expand('<cword>')
        return [[<Cmd>silent !tmux new-window 'git bisect start @ ]]
          .. sha
          .. [[; read -n 1 -s -p "press any key to close ..."'<CR>]]
      end, { buffer = 0, expr = true })
    end,
  })
end

local function diffview_init()
  vim.g.diffview_tabpagenr = -1
  vim.cmd([[
    cnoreabbr <expr> dv getcmdtype() == ':' && getcmdline() ==# 'dv' ? 'DiffviewOpen' : 'dv'
    cnoreabbr <expr> dvh getcmdtype() == ':' && getcmdline() ==# 'dvh' ? 'DiffviewFileHistory --all' : 'dvh'
    cnoreabbr <expr> dvhh getcmdtype() == ':' && getcmdline() ==# 'dvhh' ? 'DiffviewFileHistory % --all' : 'dvhh'
  ]])
end

local function diffview_opts()
  local diffview_actions = require('diffview.actions')
  return {
    hooks = {
      view_leave = function()
        vim.g.diffview_leave = true
      end,
    },
    keymaps = {
      view = {
        { 'n', 'q', '<Cmd>tabclose<CR>', { desc = 'Close tab' } },
        { 'n', '<F9>', '<Cmd>tabclose <bar>GV --all<CR>', { desc = 'Open the commit log' } },
        {
          'n',
          '<S-F9>',
          '<Cmd>tabclose <bar>GV --name-status --all<CR>',
          { desc = 'Open the commit log --name-status' },
        },
        {
          'n',
          '<leader>s',
          diffview_actions.toggle_stage_entry,
          { desc = 'Stage / unstage the selected entry' },
        },
        {
          'n',
          '<leader>cx',
          diffview_actions.conflict_choose('all'),
          { desc = 'Choose all the versions of a conflict' },
        },
        {
          'n',
          '<leader>cX',
          diffview_actions.conflict_choose_all('all'),
          { desc = 'Choose all the versions of a conflict for the whole file' },
        },
        ['<leader>ca'] = false,
        ['<leader>cA'] = false,
      },
      file_panel = {
        ['L'] = false,
        {
          'n',
          'M',
          diffview_actions.open_commit_log,
          { desc = 'Open the commit log panel' },
        },
        {
          'n',
          'q',
          '<Cmd>tabclose<CR>',
          { desc = 'Close tab' },
        },
        {
          'n',
          'cc',
          '<Cmd>tabclose <bar> silent !tmux new-window \'git commit; read -n 1 -s -p "press any key to close ..."\'<CR>',
          { desc = 'Commit' },
        },
        {
          'n',
          'cC',
          '<Cmd>tabclose <bar> silent !tmux new-window \'git commit -n; read -n 1 -s -p "press any key to close ..."\'<CR>',
          { desc = 'Commit no verify' },
        },
        {
          'n',
          'ca',
          '<Cmd>tabclose <bar> silent !tmux new-window \'git commit --amend; read -n 1 -s -p "press any key to close ..."\'<CR>',
          { desc = 'Commit amend' },
        },
        {
          'n',
          'cA',
          '<Cmd>tabclose <bar> silent !tmux new-window \'git commit --amend -n; read -n 1 -s -p "press any key to close ..."\'<CR>',
          { desc = 'Commit amend no verify' },
        },
        {
          'n',
          'ce',
          '<Cmd>tabclose <bar> silent !tmux new-window \'git commit --amend --no-edit; read -n 1 -s -p "press any key to close ..."\'<CR>',
          { desc = 'Commit amend no edit' },
        },
        {
          'n',
          'cE',
          '<Cmd>tabclose <bar> silent !tmux new-window \'git commit --amend --no-edit -n; read -n 1 -s -p "press any key to close ..."\'<CR>',
          { desc = 'Commit amend no edit no-verify' },
        },
        {
          'n',
          '<F9>',
          '<Cmd>tabclose <bar>GV --all<CR>',
          { desc = 'Open the commit log' },
        },
        {
          'n',
          '<S-F9>',
          '<Cmd>tabclose <bar>GV --name-status --all<CR>',
          { desc = 'Open the commit log --name-status' },
        },
        {
          'n',
          't',
          diffview_actions.goto_file_tab,
          { desc = 'Open the file in a new tabpage' },
        },
      },
      file_history_panel = {
        ['L'] = false,
        { 'n', 'M', diffview_actions.open_commit_log, { desc = 'Show commit details' } },
        { 'n', 'q', '<Cmd>tabclose<CR>', { desc = 'Close tab' } },
      },
    },
  }
end

local function diffview_config(_, opts)
  local diffview_close_augroup = vim.api.nvim_create_augroup('DiffviewClose', {})
  vim.api.nvim_create_autocmd('TabEnter', {
    group = diffview_close_augroup,
    callback = function(_)
      if vim.g.diffview_leave and vim.fn.tabpagenr('#') ~= 0 then
        vim.cmd.tabclose(vim.fn.tabpagenr('#'))
        vim.g.diffview_leave = nil
      end
    end,
  })

  require('diffview').setup(opts)
end

return {
  {
    'https://github.com/airblade/vim-gitgutter',
    event = 'VeryLazy',
    init = gitgutter_init,
    config = gitgutter_config,
  },
  {
    'https://github.com/tpope/vim-fugitive',
    cmd = { 'G', 'Git' },
    dependencies = {
      {
        'https://github.com/tpope/vim-rhubarb',
        cmd = { 'GBrowse', 'Gbrowse' },
        dependencies = {
          'https://github.com/tpope/vim-fugitive',
        },
      },
    },
  },
  {
    'https://github.com/junegunn/gv.vim',
    cmd = 'GV',
    dependencies = {
      'https://github.com/tpope/vim-fugitive',
    },
    config = gv_config,
  },
  {
    'https://github.com/sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      { '<F10>', '<Cmd>DiffviewFileHistory % --all<CR>' },
    },
    dependencies = {
      'https://github.com/nvim-tree/nvim-web-devicons',
    },
    init = diffview_init,
    opts = diffview_opts,
    config = diffview_config,
  },
}
