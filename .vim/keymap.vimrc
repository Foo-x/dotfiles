" normal mode
"" display lines downward
nnoremap j gj
nnoremap <Down> gj

"" display lines upward
nnoremap k gk
nnoremap <Up> gk

noremap <CR> G
noremap <BS> gg
noremap Y y$
nnoremap <C-j> i<CR><Esc>

nnoremap + <C-a>
nnoremap - <C-x>

noremap <Space>h ^
noremap <Space>l $
noremap <Space>m %
nnoremap <Space>/ *

nnoremap <Space>o o<Esc>
nnoremap <Space>O O<Esc>

nnoremap <Space>j <C-f>
nnoremap <Space>k <C-b>

"" insert only one character
nnoremap <Space>i i_<Esc>r

nmap <Space>w [window]
nnoremap [window]s :<C-u>split<CR>
nnoremap [window]v :<C-u>vsplit<CR>
nnoremap [window]h <C-w>h
nnoremap [window]j <C-w>j
nnoremap [window]k <C-w>k
nnoremap [window]l <C-w>l
nnoremap [window]H <C-w>H
nnoremap [window]J <C-w>J
nnoremap [window]K <C-w>K
nnoremap [window]L <C-w>L
nnoremap [window]= <C-w>=
nnoremap [window]> <C-w>>
nnoremap [window]< <C-w><
nnoremap [window]+ <C-w>+
nnoremap [window]- <C-w>-

nmap <Space>t [tab]
nnoremap [tab]t :<C-u>tabnew<CR>
nnoremap [tab]h gT
nnoremap [tab]j gT
nnoremap [tab]k gt
nnoremap [tab]l gt

"" not to yunk
nnoremap x "_x
nnoremap X "_X
nnoremap s "_s
nnoremap S "_S

"" format all lines
nnoremap <Space>= gg=G

"" yank all lines
nnoremap <Space>y ggyG

"" move to end after pasting
nnoremap <silent> p p`]

nnoremap <Space>s :%s/

"" disable highlight
nmap <Esc><Esc> :nohlsearch<CR><Esc>

"" correct quit
nnoremap q: :q

" insert mode
inoremap <C-e> <END>
inoremap <C-a> <HOME>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-u> <BS>
inoremap <C-i> <Del>
inoremap jj    <Esc>
inoremap jk    <CR>

" visual mode
"" search selected and go next
vnoremap * "zy:let @/ = @z<CR>n

"" search selected and go previous
vnoremap # "zy:let @/ = @z<CR>N

"" move to end after yank
vnoremap <silent> y y`]

vnoremap <Space>s( di()<Esc>P
vnoremap <Space>s{ di{}<Esc>P
vnoremap <Space>s[ di[]<Esc>P
vnoremap <Space>s< di<><Esc>P
vnoremap <Space>s" di""<Esc>P
vnoremap <Space>s' di''<Esc>P
