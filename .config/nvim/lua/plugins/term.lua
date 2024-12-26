local toggleterm_opts = {}

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
    vim.schedule(function()
      vim.cmd.stopinsert()
    end)
  end, { nargs = '+', range = true })
  vim.api.nvim_create_user_command('TermExecTab', function(param)
    vim.cmd(math.max(param.count, 1) .. 'TermExec direction="tab" cmd="' .. param.args .. '"')
    vim.schedule(function()
      vim.cmd.stopinsert()
    end)
  end, { nargs = '+', range = true })
  vim.api.nvim_create_user_command('TermExecBackground', function(param)
    vim.cmd(math.max(param.count, 1) .. 'TermExec open=0 cmd="' .. param.args .. '"')
    vim.schedule(function()
      vim.cmd.stopinsert()
    end)
  end, { nargs = '+', range = true })

  vim.keymap.set({ 'n', 't' }, '<C-t>', function()
    return '<Cmd>' .. vim.v.count .. 'ToggleTerm direction="tab"<CR>'
  end, { expr = true })
  vim.keymap.set({ 'n', 't' }, '<C-\\>', function()
    return '<Cmd>' .. vim.v.count .. 'ToggleTerm direction="vertical" size=' .. vim.o.columns / 2 .. '<CR>'
  end, { expr = true })

  -- git
  vim.keymap.set('n', '<Plug>(git)<Space>', ':<C-u>2TermExecVertical git ')
  vim.keymap.set('n', '<Plug>(git)cc', '<Cmd>1TermExecTab git commit<CR>')
  vim.keymap.set('n', '<Plug>(git)cC', '<Cmd>1TermExecTab git commit -n<CR>')
  vim.keymap.set('n', '<Plug>(git)ca', '<Cmd>1TermExecTab git commit --amend<CR>')
  vim.keymap.set('n', '<Plug>(git)cA', '<Cmd>1TermExecTab git commit --amend -n<CR>')
  vim.keymap.set('n', '<Plug>(git)ce', '<Cmd>1TermExecTab git commit --amend --no-edit<CR>')
  vim.keymap.set('n', '<Plug>(git)cE', '<Cmd>1TermExecTab git commit --amend --no-edit -n<CR>')
  vim.keymap.set('n', '<Plug>(git)b<CR>', '<Cmd>2TermExecVertical git branch<CR>')
  vim.keymap.set('n', '<Plug>(git)ba', '<Cmd>2TermExecVertical git branch -a<CR>')
  vim.keymap.set('n', '<Plug>(git)bv', '<Cmd>2TermExecVertical git branch -avv<CR>')
  vim.keymap.set('n', '<Plug>(git)s<CR>', '<Cmd>2TermExecVertical git status -sb<CR>')
  vim.keymap.set('n', '<Plug>(git)f', '<Cmd>2TermExecBackground git fetch<CR>')
  vim.keymap.set('n', '<Plug>(git)p<CR>', '<Cmd>2TermExecBackground git pull<CR>')
  vim.keymap.set('n', '<Plug>(git)pp', '<Cmd>2TermExecBackground git pp<CR>')
  vim.keymap.set('n', '<Plug>(git)ps', '<Cmd>2TermExecVertical git push<CR>')
  vim.keymap.set('n', '<Plug>(git)sl', '<Cmd>2TermExecVertical git stash list<CR>')
  vim.keymap.set('n', '<Plug>(git)ui', function()
    Terminal:new({
      cmd = 'gitui',
      direction = 'tab',
      close_on_exit = true,
    }):toggle()
  end)

  -- jj
  vim.keymap.set('n', '<Plug>(jj)<Space>', ':<C-u>2TermExecVertical jj ')
  vim.keymap.set('n', '<Plug>(jj)bc', ':<C-u>2TermExecVertical jj bookmark create ')
  vim.keymap.set('n', '<Plug>(jj)bl', '<Cmd>2TermExecVertical jj bookmark list<CR>')
  vim.keymap.set('n', '<Plug>(jj)c<CR>', '<Cmd>1TermExecTab jj commit<CR>')
  vim.keymap.set('n', '<Plug>(jj)ci', '<Cmd>1TermExecTab jj commit --interactive<CR>')
  vim.keymap.set('n', '<Plug>(jj)d', '<Cmd>1TermExecTab jj describe<CR>')
  vim.keymap.set('n', '<Plug>(jj)gf', '<Cmd>2TermExecBackground jj git fetch<CR>')
  vim.keymap.set('n', '<Plug>(jj)gp<CR>', '<Cmd>2TermExecVertical jj git push<CR>')
  vim.keymap.set('n', '<Plug>(jj)gpb', ':<C-u>2TermExecVertical jj git push --bookmark ')
  vim.keymap.set('n', '<Plug>(jj)n', '<Cmd>2TermExecVertical jj new<CR>')
  vim.keymap.set('n', '<Plug>(jj)sh', '<Cmd>1TermExecTab jj show<CR>')
  vim.keymap.set('n', '<Plug>(jj)sp<CR>', '<Cmd>1TermExecTab jj split<CR>')
  vim.keymap.set('n', '<Plug>(jj)spp', '<Cmd>1TermExecTab jj split --parallel<CR>')
  vim.keymap.set('n', '<Plug>(jj)sq<CR>', '<Cmd>2TermExecVertical jj squash<CR>')
  vim.keymap.set('n', '<Plug>(jj)sqi', '<Cmd>1TermExecTab jj squash --interactive<CR>')
  vim.keymap.set('n', '<Plug>(jj)st', '<Cmd>2TermExecVertical jj st<CR>')
  vim.keymap.set('n', '<Plug>(jj)u', '<Cmd>2TermExecBackground jj undo<CR>')

  -- set g:termx<count> and then type <count><Space>x to execute set command
  -- i.e. let g:termx1 = 'echo foo' then type 1<Space>x will execute 'echo foo' in terminal
  -- if <count> is 1, it can be omitted
  vim.keymap.set('n', '<Space>x', function()
    vim.cmd('3TermExec cmd="' .. vim.g['termx' .. vim.v.count1] .. '"')
    vim.schedule(function()
      vim.cmd.stopinsert()
    end)
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
