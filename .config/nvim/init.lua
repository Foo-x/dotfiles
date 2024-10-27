vim.loader.enable()

vim.env.XDG_CONFIG_HOME = vim.fn.get(vim.fn.environ(), 'XDG_CONFIG_HOME', vim.env.HOME .. '/.config')

require('config.lazy')

vim.cmd.exe('"source" $XDG_CONFIG_HOME . "/vim/vimrc"')

require('user.commands')
require('user.spzenhan')
