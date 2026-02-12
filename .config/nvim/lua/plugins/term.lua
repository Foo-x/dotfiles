local toggleterm_opts = {
  start_in_insert = false,
}

local function toggleterm_config(_, opts)
  local toggleterm = require('toggleterm')
  toggleterm.setup(opts)

  function _G.on_open_toggleterm()
    vim.o.list = false
    vim.o.winfixwidth = false

    vim.keymap.set('t', '<C-]>', [[<C-\><C-n>]], { buffer = 0 })
  end

  vim.cmd([[
  augroup ToggleTerm
    autocmd!
    autocmd TermOpen term://* lua on_open_toggleterm()
    autocmd BufEnter * if &buftype ==# 'terminal' | sleep 1m | startinsert | endif
    autocmd FileType fzf lua vim.keymap.del("t", "<C-]>", { buffer = 0 })
  augroup END
  ]])

  local Terminal = require('toggleterm.terminal').Terminal
  local common = Terminal:new({ id = 1, direction = 'tab', on_open = on_open_toggleterm })
  common:spawn()
  local git = Terminal:new({ id = 2, display_name = 'git', direction = 'vertical', on_open = on_open_toggleterm })
  git:spawn()
  local termx = Terminal:new({ id = 3, display_name = 'termx', direction = 'tab', on_open = on_open_toggleterm })
  termx:spawn()

  vim.api.nvim_create_user_command('TermExecVertical', function(param)
    vim.cmd(
      math.max(param.count, 1)
        .. 'TermExec direction="vertical" size='
        .. vim.o.columns / 2
        .. ' cmd="'
        .. param.args
        .. '"'
    )
  end, { nargs = '+', range = true })
  vim.api.nvim_create_user_command('TermExecTab', function(param)
    vim.cmd(math.max(param.count, 1) .. 'TermExec direction="tab" cmd="' .. param.args .. '"')
  end, { nargs = '+', range = true })
  vim.api.nvim_create_user_command('TermExecBackground', function(param)
    vim.cmd(math.max(param.count, 1) .. 'TermExec open=0 cmd="' .. param.args .. '"')
  end, { nargs = '+', range = true })

  vim.keymap.set({ 'n', 't' }, '<C-t>', function()
    return '<Cmd>' .. vim.v.count .. 'ToggleTerm direction="tab"<CR>'
  end, { expr = true })
  vim.keymap.set({ 'n', 't' }, '<C-\\>', function()
    return '<Cmd>' .. vim.v.count .. 'ToggleTerm direction="vertical" size=' .. vim.o.columns / 2 .. '<CR>'
  end, { expr = true })

  -- set g:termx<count> and then type <count><Space>x to execute set command
  -- i.e. let g:termx1 = 'echo foo' then type 1<Space>x will execute 'echo foo' in terminal
  -- if <count> is 1, it can be omitted
  vim.keymap.set('n', '<Space>x', function()
    vim.cmd('3TermExec cmd="' .. vim.g['termx' .. vim.v.count1] .. '"')
  end)
end

local function vim_test_init()
  vim.g['test#strategy'] = {
    nearest = 'toggleterm',
    file = 'dispatch',
    suite = 'dispatch',
  }
  vim.keymap.set('n', '<Leader>t', '<Cmd>TestLast<CR>')
  vim.g['test#javascript#vitest#options'] = '--no-color'
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
    dependencies = {
      'https://github.com/tpope/vim-dispatch',
    },
    cmd = { 'TestNearest', 'TestFile', 'TestSuite', 'TestLast' },
    init = vim_test_init,
  },
}
