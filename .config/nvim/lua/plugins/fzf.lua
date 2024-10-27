local function fzf_config()
  vim.cmd [[
    fun! s:fern_reveal(line)
      exe 'Fern . -drawer -reveal=' . a:line
    endf
    command! FFern exe "norm \<Plug>(fern-close-drawer)" | call fzf#run(fzf#wrap({
      \ 'source': 'bfs d',
      \ 'sink': function('s:fern_reveal'),
      \ 'options': '--prompt "FFern> "'
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
    config = fzf_config
  },
}
