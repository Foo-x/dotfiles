" set
set clipboard=unnamed

" map
unmap <Space>

nnoremap j gj
nnoremap k gk

nnoremap Y y$
nnoremap U <C-r>

nnoremap + <C-a>
nnoremap - <C-x>

nnoremap ; :
nnoremap : ;

nnoremap <Space>h ^
nnoremap <Space>l $

nnoremap J <C-f>
nnoremap K <C-b>

"" not to yunk
nnoremap x "_x
nnoremap X "_X
nnoremap s "_s
nnoremap S "_S

"" select all
nnoremap <Space>v ggVG

"" delete all
nnoremap <Space>d ggdG

exmap back obcommand app:go-back
nnoremap <C-o> :back<CR>
exmap forward obcommand app:go-forward
nnoremap <C-i> :forward<CR>

nnoremap <Space>s :%s//g<Left><Left>

"" toggle highlight
nnoremap <C-l> <C-l>:nohls<CR>

inoremap jk <Esc>

vnoremap <S-j> <C-f>
vnoremap <S-k> <C-b>

vnoremap j gj
vnoremap k gk

vnoremap + <C-a>gv
vnoremap - <C-x>gv
vnoremap g+ g<C-a>gv
vnoremap g- g<C-x>gv

"" not to override register on paste
vnoremap p pgvy

"" continue visual mode after indenting
vnoremap > >gv
vnoremap < <gv

"" move to end after yank
vnoremap <silent> y y`]

vnoremap <Space>l $
