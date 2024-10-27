local function kmd_syntax()
  vim.cmd [[
    hi link KmdContext Changed
    hi link KmdTag Added
    hi link KmdDue Removed
  ]]

  -- do nothing if kmd syntax is already set
  local syntax_list = vim.api.nvim_exec2('syntax list', { output = true }).output
  if string.find(syntax_list, 'KmdContext') then
    return
  end

  vim.cmd [[
    windo syntax match KmdContext display " @\S\+"
    windo syntax match KmdTag display " +\S\+"
    windo syntax match KmdDue display " \~\d\{4\}-\d\{2\}-\d\{2\}"
  ]]
end

vim.api.nvim_create_user_command('Everforest', function()
  vim.cmd('color everforest')
  local config = vim.fn['everforest#get_configuration']()
  local palette = vim.fn['everforest#get_palette']('medium', config)
  vim.cmd('hi GitGutterAdd guifg=' .. palette.green[1])
  vim.cmd('hi GitGutterChange guifg=' .. palette['blue'][1])
  vim.cmd('hi GitGutterDelete guifg=' .. palette['red'][1])
  vim.cmd('hi GitGutterChangeDelete guifg=' .. palette['purple'][1])
  kmd_syntax()
end, {})

vim.api.nvim_create_user_command('Iceberg', function()
  vim.cmd [[
    color iceberg
    hi GitGutterAdd guibg=none
    hi GitGutterChange guibg=none
    hi GitGutterDelete guibg=none
    hi GitGutterChangeDelete guibg=none
    hi SignColumn guibg=none
    hi FoldColumn guibg=none
  ]]
  kmd_syntax()
end, {})

vim.api.nvim_create_user_command('Base16GrayscaleDark', function()
  vim.cmd('color base16-grayscale-dark')
end, {})

vim.api.nvim_create_user_command('NoirbuddySlate', function()
  vim.cmd('hi clear')
  require('noirbuddy').setup({
    preset = 'slate',
    colors = {
      diagnostic_error = '#884444',
      diagnostic_warning = '#887744',
      diagnostic_info = '#535353',
      diagnostic_hint = '#535353',
      diff_add = '#6688AA',
      diff_change = '#77AA77',
      diff_delete = '#AA6666',
    }
  })
  vim.cmd [[
    hi DiffText guifg=#f5f5f5 guibg=#336633
    hi GitGutterAdd guifg=#6688AA
    hi GitGutterChange guifg=#77AA77
    hi GitGutterDelete guifg=#AA6666
    hi FoldColumn guibg=bg
    hi Visual guibg=#446688 guifg=white
    hi IncSearch guibg=#554433 guifg=white
    hi Search guibg=#334455 guifg=white
    hi MoreMsg guibg=bg
    hi NormalFloat guibg=#222229
    hi Cursor guibg=#f5f5f5 guifg=#323232
    hi @ibl.indent.char.1 gui=nocombine guifg=#323232
    hi @ibl.whitespace.char.1 gui=nocombine guifg=#323232
    hi @ibl.scope.char.1 gui=nocombine guifg=#737373
    hi @ibl.scope.underline.1 gui=underline guisp=#737373
    hi Comment guifg=#737373
    hi @comment guifg=#737373
    hi NonText guifg=#535353
    hi LineNr guifg=#434343
    hi LspReferenceText guibg=#323232
    hi LspReferenceRead guibg=#323232
    hi LspReferenceWrite guibg=#323232
    hi link CodeiumSuggestion NonText
  ]]

  require('leap').init_highlight(true)
  kmd_syntax()
end, {})

vim.api.nvim_create_user_command('Color', function(param)
  vim.cmd(param)
end, {
  nargs = 1,
  complete = function()
    return { 'Everforest', 'Iceberg', 'Base16GrayscaleDark', 'NoirbuddySlate' }
  end,
})

vim.cmd('hi netrwMarkFile ctermbg=darkmagenta')

local function noirbuddy_config()
  vim.cmd('NoirbuddySlate')
end

return {
  {
    'https://github.com/sainnhe/everforest',
    lazy = true,
  },
  {
    'https://github.com/cocopon/iceberg.vim',
    lazy = true,
  },
  {
    'https://github.com/RRethy/nvim-base16',
    lazy = true,
  },
  {
    'https://github.com/jesseleite/nvim-noirbuddy',
    dependencies = {
      { 'https://github.com/tjdevries/colorbuddy.nvim' }
    },
    lazy = false,
    priority = 1000,
    config = noirbuddy_config,
  },
}
