local treesitter_opts = {
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
  sync_install = false,
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = 'v',
      node_decremental = 'V',
    },
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
        [']c'] = '@comment.outer',
        [']f'] = '@function.outer',
        [']s'] = { query = '@scope', query_group = 'locals' },
        [']z'] = { query = '@fold', query_group = 'folds' },
      },
      goto_next_end = {
        [']C'] = '@comment.outer',
        [']F'] = '@function.outer',
        [']S'] = { query = '@scope', query_group = 'locals' },
        [']Z'] = { query = '@fold', query_group = 'folds' },
      },
      goto_previous_start = {
        ['[c'] = '@comment.outer',
        ['[f'] = '@function.outer',
        ['[s'] = { query = '@scope', query_group = 'locals' },
        ['[z'] = { query = '@fold', query_group = 'folds' },
      },
      goto_previous_end = {
        ['[C'] = '@comment.outer',
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
}

local function treesitter_config(_, opts)
  if
    vim.fn.executable('cc') == 1
    or vim.fn.executable('gcc') == 1
    or vim.fn.executable('clang') == 1
    or vim.fn.executable('cl') == 1
    or vim.fn.executable('zig') == 1
  then
    require('nvim-treesitter.install').prefer_git = true
    require('nvim-treesitter.configs').setup(opts)
    require('nvim-ts-autotag').setup()

    vim.keymap.set('n', '[c', require('treesitter-context').go_to_context)
  end
end

return {
  {
    'https://github.com/nvim-treesitter/nvim-treesitter',
    dependencies = {
      'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
      'https://github.com/windwp/nvim-ts-autotag',
      'https://github.com/nvim-treesitter/nvim-treesitter-context',
    },
    -- treesitter cannot load with VeryLazy
    event = 'CursorHold',
    build = ':TSUpdate',
    opts = treesitter_opts,
    config = treesitter_config,
  },
}
