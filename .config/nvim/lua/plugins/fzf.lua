local function fzf_config()
  vim.cmd [[
    fun! s:fern_reveal(line)
      exe 'Fern . -drawer -reveal=' . a:line
    endf
    command! FFern exe "norm \<Plug>(fern-close-drawer)" | call fzf#run(fzf#wrap({
      \ 'source': 'bfs d',
      \ 'sink': function('s:fern_reveal'),
      \ 'options': '--prompt "Fern> "'
    \ }))

    fun! s:oil_open(line)
      let l:dir = substitute(a:line, '^\s*[.0-9]*\s*', '', '')
      exe 'Oil ' . l:dir
    endf
    command! FOil call fzf#run(fzf#wrap({
      \ 'source': 'zoxide query --list --score',
      \ 'sink': function('s:oil_open'),
      \ 'options': '--prompt "Oil> " --preview "ls --dereference-command-line -1 --sort=time --color=always {2}"'
    \ }))
  ]]
end

return {
  {
    'https://github.com/junegunn/fzf.vim',
    dependencies = {
      {
        dir = '~/.fzf'
      },
    },
    event = 'VeryLazy',
    keys = {
      { '<Plug>(fzf)e', '<Cmd>FFern<CR>' },
      { '<Plug>(fzf)o', '<Cmd>FOil<CR>' },
    },
    config = fzf_config
  },
}
