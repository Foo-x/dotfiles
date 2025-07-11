local aerial_opts = {
  keymaps = {
    ['<CR>'] = {
      callback = function()
        require('aerial').select()
        require('aerial').close()
      end,
    },
  },
  filter_kind = false,
}

local other_opts = {
  mappings = {
    {
      pattern = 'src/resources/views/(.*).blade.php',
      target = 'src/app/Http/%1.php',
      transformer = 'capitalize_by_slash',
    },
    {
      pattern = 'src/app/Http/(.*).php',
      target = 'src/resources/views/%1.blade.php',
      transformer = 'lowercase',
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
    end,
  },
}

local flash_opts = {
  modes = {
    char = {
      enabled = false,
    },
  },
}

local flash_exclusive_action = function(match, state)
  local Jump = require('flash.jump')
  local cur_pos = vim.api.nvim_win_get_cursor(0)
  if match.pos[1] < cur_pos[1] or (match.pos[1] == cur_pos[1] and match.pos[2] < cur_pos[2]) then
    state.opts.jump.offset = 1
  else
    state.opts.jump.offset = -1
  end
  Jump.jump(match, state)
  Jump.on_jump(state)
end

local flash_migemo_mode = function(s)
  -- split by space, convert with migemo, and join with space
  return table.concat(
    vim.tbl_map(function(w)
      return vim.fn['kensaku#query'](w)
    end, vim.split(s, ' ')),
    ' '
  )
end

-- without vowels
local flash_migemo_labels = 'sdfghjklqwrtypzxcvbnm'

local flash_keys = {
  {
    'f',
    mode = { 'n', 'x' },
    function()
      require('flash').jump({
        labels = flash_migemo_labels,
        search = {
          mode = flash_migemo_mode,
        },
      })
    end,
    desc = 'Flash inclusive migemo',
  },
  {
    't',
    mode = { 'n', 'x' },
    function()
      require('flash').jump({
        labels = flash_migemo_labels,
        search = {
          mode = flash_migemo_mode,
        },
        action = flash_exclusive_action,
      })
    end,
    desc = 'Flash exclusive migemo',
  },
  {
    'F',
    mode = { 'n', 'x' },
    function()
      require('flash').jump()
    end,
    desc = 'Flash inclusive',
  },
  {
    'T',
    mode = { 'n', 'x' },
    function()
      require('flash').jump({
        action = flash_exclusive_action,
      })
    end,
    desc = 'Flash exclusive',
  },
  {
    'j',
    mode = { 'o' },
    function()
      require('flash').jump({
        labels = flash_migemo_labels,
        search = {
          mode = flash_migemo_mode,
        },
        remote_op = {
          restore = true,
          motion = true,
        },
      })
    end,
    desc = 'Flash remote migemo',
  },
  {
    ':',
    mode = { 'n', 'x' },
    function()
      require('flash').jump({ continue = true })
    end,
    desc = 'Flash continue last search',
  },
}

local function kensaku_search_config()
  vim.keymap.set('c', '<C-j>', '<Plug>(kensaku-search-replace)<CR>')
end

return {
  {
    'https://github.com/stevearc/aerial.nvim',
    keys = {
      { '<leader>a', '<Cmd>AerialNavToggle<CR>' },
      { '<leader>A', '<Cmd>AerialToggle<CR>' },
    },
    opts = aerial_opts,
  },
  {
    'https://github.com/rgroli/other.nvim',
    keys = {
      { '<leader>oo', ':<C-u>Other<CR>', silent = true },
      { '<leader>ot', ':<C-u>OtherTabNew<CR>', silent = true },
      { '<leader>os', ':<C-u>OtherSplit<CR>', silent = true },
      { '<leader>ov', ':<C-u>OtherVSplit<CR>', silent = true },
      { '<leader>oc', ':<C-u>OtherClear<CR>', silent = true },
    },
    opts = other_opts,
    config = function(_, opts)
      require('other-nvim').setup(opts)
    end,
  },
  {
    'https://github.com/folke/flash.nvim',
    event = 'VeryLazy',
    opts = flash_opts,
    keys = flash_keys,
  },
  {
    'https://github.com/lambdalisue/vim-kensaku-search',
    event = 'VeryLazy',
    dependencies = {
      'https://github.com/lambdalisue/vim-kensaku',
      'https://github.com/vim-denops/denops.vim',
    },
    config = kensaku_search_config,
  },
  {
    'https://github.com/Bakudankun/BackAndForward.vim',
    event = 'VeryLazy',
    keys = {
      { '<Space><C-o>', '<Plug>(backandforward-back)' },
      { '<Space><C-i>', '<Plug>(backandforward-forward)' },
    },
  },
}
