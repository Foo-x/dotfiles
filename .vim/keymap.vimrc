" normal mode
"" display lines downward
nnoremap j gj
nnoremap <Down> gj

"" display lines upward
nnoremap k gk
nnoremap <Up> gk

noremap Y y$
nnoremap <C-j> i<CR><Esc>

nnoremap + <C-a>
nnoremap - <C-x>

"" not to go next
nnoremap * *N

"" go to parent braces/brackets/parentheses
nnoremap [[ "_ya[
nnoremap [{ "_ya{
nnoremap [( "_ya(
nnoremap [] "_ya[
nnoremap [} "_ya{
nnoremap [) "_ya(
nnoremap ][ "_ya[%
nnoremap ]{ "_ya{%
nnoremap ]( "_ya(%
nnoremap ]] "_ya[%
nnoremap ]} "_ya{%
nnoremap ]) "_ya(%

noremap <Space>h ^
nnoremap <Space>l $
vnoremap <Space>l $h
noremap <Space>m %
nnoremap <Space>/ *

nnoremap <Space>o o<Esc>
nnoremap <Space>O O<Esc>

nnoremap <Space>j <C-f>
nnoremap <Space>k <C-b>

nnoremap <Space><Space>t :<C-u>tab ter<CR>

"" insert only one character
nnoremap <Space>i i_<Esc>r

nmap <Space>w [window]
nnoremap [window]_ :<C-u>split<CR>
nnoremap [window]\ :<C-u>vsplit<CR>
nnoremap [window]c <C-w>c
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

"" select all
nnoremap <Space>v ggVG

"" delete all
nnoremap <Space>d ggdG

"" move to end after pasting
nnoremap <silent> p p`]

nnoremap <Space>s :%s/

"" disable highlight
nnoremap <C-l> :nohlsearch<CR><C-l>

"" correct quit
nnoremap q: :q

" insert mode
inoremap jj    <Esc>

" visual mode
vnoremap + <C-a>gv
vnoremap - <C-x>gv
vnoremap g+ g<C-a>gv
vnoremap g- g<C-x>gv

"" not to override register on paste
vnoremap p pgvy

"" highlight selected
vnoremap <silent> * "zy/<C-r>z<CR>N

"" continue visual mode after indenting
vnoremap > >gv
vnoremap < <gv

"" move to end after yank
vnoremap <silent> y y`]

vnoremap <Space>s( di()<Esc>P
vnoremap <Space>s{ di{}<Esc>P
vnoremap <Space>s[ di[]<Esc>P
vnoremap <Space>s< di<><Esc>P
vnoremap <Space>s" di""<Esc>P
vnoremap <Space>s' di''<Esc>P

" terminal mode
tnoremap <C-n> <C-w>N
tnoremap <silent><C-w><C-d> <C-w>N:<C-u>bd!<CR>:<C-u>q<CR>
