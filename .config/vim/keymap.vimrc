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

nmap <Space>g <Plug>(goto)
nnoremap <Plug>(goto)h <C-o>
nnoremap <Plug>(goto)l <C-i>

nmap <Space>a <Plug>(argument)
nnoremap <Plug>(argument)n :<C-u>next<CR>
nnoremap <Plug>(argument)p :<C-u>previous<CR>

nmap <Space>q <Plug>(quickfix)
nnoremap <Plug>(quickfix)n :<C-u>cnext<CR>
nnoremap <Plug>(quickfix)p :<C-u>cprevious<CR>
nnoremap <Plug>(quickfix)k :<C-u>cbefore<CR>
nnoremap <Plug>(quickfix)j :<C-u>cafter<CR>
nnoremap <Plug>(quickfix)w :<C-u>cwindow<CR>
nnoremap <Plug>(quickfix)c :<C-u>cclose<CR>
nnoremap <Plug>(quickfix). :<C-u>cgetbuffer<CR>
nnoremap <Plug>(quickfix)f :<C-u>cgetfile<CR>
nnoremap <silent> <Plug>(quickfix)e :<C-u>exe 'e' &errorfile<CR>
"" toggle quickfix
nnoremap <expr> <Plug>(quickfix)t empty(filter(getwininfo(), 'v:val.quickfix')) ? ':copen<CR>' : ':cclose<CR>'

nmap <Space><Space>l <Plug>(location)
nnoremap <Plug>(location)n :<C-u>lnext<CR>
nnoremap <Plug>(location)p :<C-u>lprevious<CR>
nnoremap <Plug>(location)k :<C-u>lbefore<CR>
nnoremap <Plug>(location)j :<C-u>lafter<CR>
nnoremap <Plug>(location)w :<C-u>lwindow<CR>
nnoremap <Plug>(location)c :<C-u>lclose<CR>
nnoremap <Plug>(location). :<C-u>lgetbuffer<CR>
nnoremap <Plug>(location)f :<C-u>lgetfile<CR>

nmap <Space>w <Plug>(window)
nnoremap <silent> <Plug>(window)_ :<C-u>split<CR>
nnoremap <silent> <Plug>(window)\ :<C-u>vsplit<CR>
nnoremap <Plug>(window)c <C-w>c
nnoremap <Plug>(window)o <C-w>o
nnoremap <Plug>(window)h <C-w>h
nnoremap <Plug>(window)j <C-w>j
nnoremap <Plug>(window)k <C-w>k
nnoremap <Plug>(window)l <C-w>l
nnoremap <Plug>(window)w <C-w>w
" TODO: dont change layout
nnoremap <Plug>(window)H <C-w>H
nnoremap <Plug>(window)J <C-w>J
nnoremap <Plug>(window)K <C-w>K
nnoremap <Plug>(window)L <C-w>L
nnoremap <Plug>(window)f <C-w>f
nnoremap <Plug>(window)F <C-w>F
nnoremap <Plug>(window)gf <C-w>gf
nnoremap <Plug>(window)gF <C-w>gF
nnoremap <Plug>(window)r <C-w>r
nnoremap <Plug>(window)m <C-w>\|<C-w>_
nnoremap <Plug>(window)= <C-w>=
nnoremap <Plug>(window)> <C-w>>
nnoremap <Plug>(window)< <C-w><
nnoremap <Plug>(window)+ <C-w>+
nnoremap <Plug>(window)- <C-w>-

nmap <Space>t <Plug>(tab)
nnoremap <silent> <Plug>(tab)t :<C-u>tabnew<CR>
nnoremap <silent> <Plug>(tab)c :<C-u>tabclose<CR>
nnoremap <silent> <Plug>(tab)o :<C-u>tabonly<CR>
nnoremap <silent> <Plug>(tab)h :<C-u>tabprevious<CR>
nnoremap <silent> <Plug>(tab)l :<C-u>tabnext<CR>

"" not to yunk
nnoremap x "_x
nnoremap X "_X
"nnoremap s "_s
"nnoremap S "_S

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

nnoremap <Space>; A;<Esc>
nnoremap <Space>, A,<Esc>

" insert mode
inoremap jj <Esc>
inoremap <C-l> <Del>
inoremap <C-z> <C-o>u
inoremap <C-y> <C-o><C-r>
inoremap <C-v>u <C-r>=nr2char(0x)<Left>

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

" terminal mode
tmap <C-o> <C-\><C-n>

" depends on FileType
augroup FileTypeMap
  autocmd!
  autocmd FileType help nnoremap <buffer> <CR> <C-]>
augroup END
