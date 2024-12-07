local aerial_opts = {
  keymaps = {
    ['<CR>'] = {
      callback = function()
        require('aerial').select()
        require('aerial').close()
      end,
    }
  },
  filter_kind = false,
}

local other_opts = {
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
}

return {
  {
    'https://github.com/stevearc/aerial.nvim',
    keys = {
      { '<M-.>', '<Cmd>AerialToggle<CR>' },
    },
    opts = aerial_opts,
  },
  {
    'https://github.com/rgroli/other.nvim',
    keys = {
      { '<leader>oo', ':<C-u>Other<CR>',       silent = true },
      { '<leader>ot', ':<C-u>OtherTabNew<CR>', silent = true },
      { '<leader>os', ':<C-u>OtherSplit<CR>',  silent = true },
      { '<leader>ov', ':<C-u>OtherVSplit<CR>', silent = true },
      { '<leader>oc', ':<C-u>OtherClear<CR>',  silent = true },
    },
    opts = other_opts,
    config = function(_, opts)
      require('other-nvim').setup(opts)
    end,
  },
  {
    'https://github.com/ggandor/leap.nvim',
    keys = {
      { 'f', '<Plug>(leap-forward-to)' },
      { 'F', '<Plug>(leap-backward-to)' },
      { 't', '<Plug>(leap-forward-till)' },
      { 'T', '<Plug>(leap-backward-till)' },
    },
  },
}
