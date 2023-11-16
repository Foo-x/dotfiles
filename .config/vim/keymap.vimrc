" normal mode
"" display lines downward
nnoremap j gj
nnoremap <Down> gj

"" display lines upward
nnoremap k gk
nnoremap <Up> gk

noremap Y y$
nnoremap U <C-r>

nnoremap + <C-a>
nnoremap - <C-x>

"" not to go next
nnoremap * *N

"" toggle number
nnoremap <Space>n :<C-u>set number!<CR>

"" go to parent braces/brackets/parentheses
nnoremap [[ "_ya[
nnoremap [{ "_ya{
nnoremap [( "_ya(
nnoremap [] "_ya[
nnoremap [} "_ya{
nnoremap [) "_ya(
nnoremap [t vato<Esc>
nnoremap ][ "_ya[%
nnoremap ]{ "_ya{%
nnoremap ]( "_ya(%
nnoremap ]] "_ya[%
nnoremap ]} "_ya{%
nnoremap ]) "_ya(%
nnoremap ]t vat<Esc>

noremap <Space>h ^
nnoremap <Space>l $
noremap <Space>m %

nnoremap <Space>o o<Esc>
nnoremap <Space>O O<Esc>

nnoremap <Space>j <C-f>
nnoremap <Space>k <C-b>

"" insert only one character
nnoremap <Space>i i_<Esc>r

nmap <Space>g [goto]
nnoremap [goto]h <C-o>
nnoremap [goto]l <C-i>

nmap <Space>a [argument]
nnoremap [argument]n :<C-u>next<CR>
nnoremap [argument]p :<C-u>previous<CR>

nmap <Space>q [quickfix]
nnoremap [quickfix]n :<C-u>cnext<CR>
nnoremap [quickfix]p :<C-u>cprevious<CR>
nnoremap [quickfix]k :<C-u>cbefore<CR>
nnoremap [quickfix]j :<C-u>cafter<CR>
nnoremap [quickfix]w :<C-u>cwindow<CR>
nnoremap [quickfix]c :<C-u>cclose<CR>
nnoremap [quickfix]. :<C-u>cgetbuffer<CR>
nnoremap [quickfix]f :<C-u>cgetfile<CR>
nnoremap <silent> [quickfix]e :<C-u>exe 'e' &errorfile<CR>
"" toggle quickfix
nnoremap <expr> [quickfix]t empty(filter(getwininfo(), 'v:val.quickfix')) ? ':copen<CR>' : ':cclose<CR>'

nmap <Space><Space>l [location]
nnoremap [location]n :<C-u>lnext<CR>
nnoremap [location]p :<C-u>lprevious<CR>
nnoremap [location]k :<C-u>lbefore<CR>
nnoremap [location]j :<C-u>lafter<CR>
nnoremap [location]w :<C-u>lwindow<CR>
nnoremap [location]c :<C-u>lclose<CR>
nnoremap [location]. :<C-u>lgetbuffer<CR>
nnoremap [location]f :<C-u>lgetfile<CR>

nmap <Space>w [window]
nnoremap <silent> [window]_ :<C-u>split<CR>
nnoremap <silent> [window]\ :<C-u>vsplit<CR>
nnoremap [window]c <C-w>c
nnoremap [window]o <C-w>o
nnoremap [window]h <C-w>h
nnoremap [window]j <C-w>j
nnoremap [window]k <C-w>k
nnoremap [window]l <C-w>l
" TODO: dont change layout
nnoremap [window]H <C-w>H
nnoremap [window]J <C-w>J
nnoremap [window]K <C-w>K
nnoremap [window]L <C-w>L
nnoremap [window]f <C-w>f
nnoremap [window]F <C-w>F
nnoremap [window]gf <C-w>gf
nnoremap [window]gF <C-w>gF
nnoremap [window]r <C-w>r
nnoremap [window]m <C-w>\|<C-w>_
nnoremap [window]= <C-w>=
nnoremap [window]> <C-w>>
nnoremap [window]< <C-w><
nnoremap [window]+ <C-w>+
nnoremap [window]- <C-w>-

nmap <Space>t [tab]
nnoremap <silent> [tab]t :<C-u>tabnew<CR>
nnoremap <silent> [tab]c :<C-u>tabclose<CR>
nnoremap <silent> [tab]o :<C-u>tabonly<CR>
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

" insert mode
inoremap jj <Esc>
inoremap <C-l> <Del>
inoremap <C-z> <C-o>u
inoremap <C-y> <C-o><C-r>

" visual mode
"" display lines downward
vnoremap j gj
vnoremap <Down> gj

"" display lines upward
vnoremap k gk
vnoremap <Up> gk

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

vnoremap <Space>l $h

vnoremap <Space>s( di()<Esc>P
vnoremap <Space>s{ di{}<Esc>P
vnoremap <Space>s[ di[]<Esc>P
vnoremap <Space>s< di<><Esc>P
vnoremap <Space>s" di""<Esc>P
vnoremap <Space>s' di''<Esc>P

vnoremap <Space>do :diffget<CR>
vnoremap <Space>1do :diffget 1<CR>
vnoremap <Space>2do :diffget 2<CR>
vnoremap <Space>3do :diffget 3<CR>
vnoremap <Space>dp :diffput<CR>
vnoremap <Space>1dp :diffput 1<CR>
vnoremap <Space>2dp :diffput 2<CR>
vnoremap <Space>3dp :diffput 3<CR>
