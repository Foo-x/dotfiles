local toggleterm_opts = {
  open_mapping = [[<c-\>]],
  direction = 'tab',
}

local function toggleterm_config(_, opts)
  local toggleterm = require('toggleterm')
  toggleterm.setup(opts)

  function _G.on_open_toggleterm()
    vim.o.list = false

    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { buffer = 0 })
  end

  vim.cmd([[
  augroup ToggleTerm
    autocmd!
    autocmd TermOpen term://* lua on_open_toggleterm()
    autocmd FileType fzf lua vim.keymap.del("t", "<Esc>", { buffer = 0 })
  augroup END
  ]])

  local Terminal = require('toggleterm.terminal').Terminal
  local common = Terminal:new({ id = 1, direction = 'tab', on_open = on_open_toggleterm })
  common:spawn()
  local git = Terminal:new({ id = 2, display_name = 'git', direction = 'vertical', on_open = on_open_toggleterm })
  git:spawn()

  local function term_exec_git(cmd)
    if not git:is_open() then
      git:open(vim.o.columns / 2)
    end
    git:send('git ' .. cmd, true)
    vim.schedule(function()
      vim.cmd.stopinsert()
    end)
  end
  local function term_exec_git_background(cmd)
    git:send('git ' .. cmd, true)
  end
  vim.keymap.set('n', '<Plug>(git)<CR>', ':2TermExec size=' .. vim.o.columns / 2 .. ' cmd="git "<Left>')
  vim.keymap.set('n', '<Plug>(git)b<CR>', function()
    term_exec_git('branch')
  end)
  vim.keymap.set('n', '<Plug>(git)ba', function()
    term_exec_git('branch -a')
  end)
  vim.keymap.set('n', '<Plug>(git)bv', function()
    term_exec_git('branch -avv')
  end)
  vim.keymap.set('n', '<Plug>(git)s<CR>', function()
    term_exec_git('status -sb')
  end)
  vim.keymap.set('n', '<Plug>(git)f', function()
    term_exec_git_background('fetch')
  end)
  vim.keymap.set('n', '<Plug>(git)p<CR>', function()
    term_exec_git_background('pull')
  end)
  vim.keymap.set('n', '<Plug>(git)pp', function()
    term_exec_git_background('pp')
  end)
  vim.keymap.set('n', '<Plug>(git)ps', function()
    term_exec_git('push')
  end)
  vim.keymap.set('n', '<Plug>(git)sl', function()
    term_exec_git('stash list')
  end)
  -- set g:termx<count> and then type <count><Space>x to execute set command
  -- i.e. let g:termx1 = 'echo foo' then type 1<Space>x will execute 'echo foo' in terminal
  -- if <count> is 1, it can be omitted on typing
  vim.keymap.set('n', '<Space>x', function()
    local cmd = vim.g['termx' .. vim.v.count1]
    if cmd then
      toggleterm.exec(cmd)
    end
  end)
end

local function vim_test_init()
  vim.g['test#strategy'] = 'toggleterm'
end

return {
  {
    'https://github.com/akinsho/toggleterm.nvim',
    event = 'VeryLazy',
    opts = toggleterm_opts,
    config = toggleterm_config,
  },
  {
    'https://github.com/vim-test/vim-test',
    cmd = { 'TestNearest', 'TestClass', 'TestFile', 'TestSuite', 'TestLast', 'TestVisit' },
    init = vim_test_init,
  },
}
