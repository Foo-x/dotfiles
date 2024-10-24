" options {{{
set ignorecase
set smartcase
set incsearch

" search from the top if reaches the end
set wrapscan

" no highlight by default
set nohlsearch
" }}}

" keymap {{{
nnoremap <Space>s :%s//g<Left><Left>

" toggle highlight
nnoremap <C-l> <C-l>:set hlsearch!<CR>

"" highlight selected
vnoremap <silent> * "zy:exe '/\V' . escape(@z, '\\/')<CR>N
" }}}
