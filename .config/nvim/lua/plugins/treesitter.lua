local function treesitter_config()
  if
    vim.fn.executable('cc') == 1
    or vim.fn.executable('gcc') == 1
    or vim.fn.executable('clang') == 1
    or vim.fn.executable('cl') == 1
    or vim.fn.executable('zig') == 1
  then
    require('nvim-treesitter').setup({
      install_dir = vim.fn.stdpath('data') .. '/site',
    })
    local filetypes = {
      'bash',
      'css',
      'csv',
      'dockerfile',
      'git_config',
      'gitattributes',
      'gitcommit',
      'gitignore',
      'html',
      'http',
      'javascript',
      'json',
      'json5',
      'lua',
      'markdown',
      'markdown_inline',
      'mermaid',
      'nix',
      'nu',
      'python',
      'readline',
      'regex',
      'scss',
      'sql',
      'terraform',
      'tmux',
      'toml',
      'typescript',
      'tsv',
      'tsx',
      'vim',
      'vimdoc',
      'yaml',
    }
    require('nvim-treesitter').install(filetypes)
    require('nvim-ts-autotag').setup()

    vim.api.nvim_create_autocmd({ 'FileType' }, {
      pattern = filetypes,
      callback = function()
        local max_filesize = 100 * 1024 -- 100 KB
        local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
        if size > max_filesize then
          return
        end

        -- check column lengths
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for _, line in ipairs(lines) do
          if #line > vim.o.synmaxcol then
            return
          end
        end

        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.wo.foldmethod = 'expr'
      end,
    })

    vim.keymap.set('n', '[c', function()
      require('treesitter-context').go_to_context(vim.v.count1)
    end)
  end
end

local function treesitter_textobjects_config()
  require('nvim-treesitter-textobjects').setup({})
  -- select
  vim.keymap.set({ 'x', 'o' }, 'af', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'if', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'as', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@locals.scope', 'locals')
  end)
  -- move
  vim.keymap.set({ 'n', 'x', 'o' }, ']c', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@comment.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']s', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@locals.scope', 'locals')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']z', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@fold', 'folds')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']C', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@comment.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']F', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']S', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@locals.scope', 'locals')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']Z', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@fold', 'folds')
  end)
  -- vim.keymap.set({ 'n', 'x', 'o' }, '[c', function()
  --   require('nvim-treesitter-textobjects.move').goto_next_start('@comment.outer', 'textobjects')
  -- end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[s', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@locals.scope', 'locals')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[z', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@fold', 'folds')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[C', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@comment.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[F', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[S', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@locals.scope', 'locals')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[Z', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@fold', 'folds')
  end)
end

return {
  {
    'https://github.com/nvim-treesitter/nvim-treesitter',
    dependencies = {
      'https://github.com/windwp/nvim-ts-autotag',
      'https://github.com/nvim-treesitter/nvim-treesitter-context',
    },
    -- treesitter cannot load with VeryLazy
    event = 'CursorHold',
    build = ':TSUpdate',
    config = treesitter_config,
  },
  {
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = treesitter_textobjects_config,
  },
}
