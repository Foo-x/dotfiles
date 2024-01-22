" options {{{
set ignorecase
set smartcase
set incsearch

" search from the top if reaches the end
set wrapscan

" highlight
set hlsearch
" }}}

" keymap {{{
nnoremap <Space>s :%s//g<Left><Left>

" disable highlight
nnoremap <C-l> :nohlsearch<CR><C-l>

"" highlight selected
vnoremap <silent> * "zy:exe '/\V' . escape(@z, '\\/')<CR>N
" }}}
