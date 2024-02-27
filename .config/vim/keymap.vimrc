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

nnoremap ; :
nnoremap : ;
nnoremap , @:

nnoremap gf gF

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

nnoremap <Space>o :<C-u>a<CR><CR>.<CR>
nnoremap <Space>O :<C-u>i<CR><CR>.<CR>

nnoremap <S-j> <C-f>
nnoremap <S-k> <C-b>

nmap <Space>a <Plug>(argument)
nnoremap <Plug>(argument)r :<C-u>Args<CR>
nnoremap <Plug>(argument)n :<C-u>next<CR>
nnoremap <Plug>(argument)p :<C-u>previous<CR>

nmap <Space>q <Plug>(quickfix)
nnoremap <Plug>(quickfix)n :<C-u>cnext<CR>
nnoremap <Plug>(quickfix)p :<C-u>cprevious<CR>
nnoremap <Plug>(quickfix)k :<C-u>cbefore<CR>
nnoremap <Plug>(quickfix)j :<C-u>cafter<CR>
nnoremap <Plug>(quickfix)w :<C-u>cwindow<CR>
nnoremap <Plug>(quickfix)c :<C-u>cclose<CR>
nnoremap <Plug>(quickfix)o :<C-u>copen<CR>
nnoremap <Plug>(quickfix). :<C-u>cgetbuffer<CR>
nnoremap <Plug>(quickfix)f :<C-u>cgetfile<CR>
nnoremap <Plug>(quickfix)h :<C-u>colder<CR>
nnoremap <Plug>(quickfix)l :<C-u>cnewer<CR>
nnoremap <expr> <Plug>(quickfix)H ':<C-u>' . (v:count > 0 ? v:count : '') . 'chistory<CR>'
nnoremap <Plug>(quickfix)e <Cmd>exe 'e' &errorfile<CR>
"" toggle quickfix
nnoremap <expr> <Plug>(quickfix)t empty(filter(getwininfo(), 'v:val.quickfix')) ? ':copen<CR>' : ':cclose<CR>'

nmap <Space><Space>l <Plug>(location)
nnoremap <Plug>(location)n :<C-u>lnext<CR>
nnoremap <Plug>(location)p :<C-u>lprevious<CR>
nnoremap <Plug>(location)k :<C-u>lbefore<CR>
nnoremap <Plug>(location)j :<C-u>lafter<CR>
nnoremap <Plug>(location)w :<C-u>lwindow<CR>
nnoremap <Plug>(location)c :<C-u>lclose<CR>
nnoremap <Plug>(location)o :<C-u>lopen<CR>
nnoremap <Plug>(location). :<C-u>lgetbuffer<CR>
nnoremap <Plug>(location)f :<C-u>lgetfile<CR>
nnoremap <Plug>(location)h :<C-u>lolder<CR>
nnoremap <Plug>(location)l :<C-u>lnewer<CR>
"" toggle location list
nnoremap <expr> <Plug>(location)t empty(filter(getwininfo(), 'v:val.loclist')) ? ':lopen<CR>' : ':lclose<CR>'

nmap <Space>w <Plug>(window)
nnoremap <Plug>(window)_ <Cmd>split<CR>
nnoremap <Plug>(window)\ <Cmd>vsplit<CR>
nnoremap <Plug>(window)c <C-w>c
nnoremap <Plug>(window)o <C-w>o
nnoremap <Plug>(window)h <C-w>h
nnoremap <Plug>(window)j <C-w>j
nnoremap <Plug>(window)k <C-w>k
nnoremap <Plug>(window)l <C-w>l
nnoremap <Plug>(window)w <C-w>w
nnoremap <Plug>(window)H <Cmd>call MoveWindow('h')<CR>
nnoremap <Plug>(window)J <Cmd>call MoveWindow('j')<CR>
nnoremap <Plug>(window)K <Cmd>call MoveWindow('k')<CR>
nnoremap <Plug>(window)L <Cmd>call MoveWindow('l')<CR>
nnoremap <Plug>(window)f <C-w>f
nnoremap <Plug>(window)F <C-w>F
nnoremap <Plug>(window)gf <C-w>gF
nnoremap <Plug>(window)T <C-w>T
nnoremap <Plug>(window)r <C-w>r
nnoremap <Plug>(window)m <C-w>\|<C-w>_
nnoremap <Plug>(window)= <C-w>=
nnoremap <Plug>(window)> <C-w>>
nnoremap <Plug>(window)< <C-w><
nnoremap <Plug>(window)+ <C-w>+
nnoremap <Plug>(window)- <C-w>-
nnoremap <Plug>(window)t <Cmd>tab split<CR>
nnoremap <Space>1 <C-w>t
nnoremap <Space>2 <C-w>t<C-w>l
nnoremap <Space>3 <C-w>t<C-w>j
nnoremap <Space>4 <C-w>b

nmap <Space>t <Plug>(tab)
nnoremap <Plug>(tab)t <Cmd>tabnew<CR>
nnoremap <Plug>(tab)f <Cmd>tabfirst<CR>
nnoremap <Plug>(tab)c <Cmd>tabclose<CR>
nnoremap <Plug>(tab)o <Cmd>tabonly<CR>
nnoremap <Plug>(tab)h <Cmd>tabprevious<CR>
nnoremap <Plug>(tab)l <Cmd>tabnext<CR>
nnoremap H <Cmd>tabprevious<CR>
nnoremap L <Cmd>tabnext<CR>
nnoremap <Plug>(tab)H <Cmd>tabmove -<CR>
nnoremap <Plug>(tab)L <Cmd>tabmove +<CR>

nmap <Space>r <Plug>(reload)
nnoremap <Plug>(reload) :<C-u>source $MYVIMRC<CR>

nnoremap <C-s> :<C-u>update<CR>

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

"" select last pasted
nnoremap gpv `[v`]

nnoremap <Space>; A;<Esc>
nnoremap <Space>, A,<Esc>

nnoremap <M-z> :<C-u>set wrap!<CR>

" insert mode
inoremap jj <Esc>
inoremap ｊｊ <Esc>
inoremap <C-l> <Del>
inoremap <C-z> <C-o>u
inoremap <C-y> <C-o><C-r>
inoremap <C-v>u <C-r>=nr2char(0x)<Left>
inoremap <C-s> <Esc>:<C-u>update<CR>gi
inoremap <Left> <C-g>U<Left>
inoremap <Right> <C-g>U<Right>
inoremap <CR> <C-g>u<CR>

imap <C-f> <Plug>(i_file)
"" relative
inoremap <Plug>(i_file). <C-r>%
"" absolute
inoremap <Plug>(i_file)p <C-r>=expand('%:p')<CR>
"" basename
inoremap <Plug>(i_file)t <C-r>=expand('%:t')<CR>
"" basename without extension
inoremap <Plug>(i_file)r <C-r>=expand('%:t:r')<CR>

" visual mode
vnoremap <S-j> <C-f>
vnoremap <S-k> <C-b>

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

vnoremap ; :
vnoremap : ;

"" not to override register on paste
vnoremap p pgvy

"" continue visual mode after indenting
vnoremap > >gv
vnoremap < <gv

"" move to end after yank
vnoremap <silent> y y`]

vnoremap <Space>l $h

vnoremap <Space>s( <Esc>`<i(<Esc>`>la)<Esc>
vnoremap <Space>s{ <Esc>`<i{<Esc>`>la}<Esc>
vnoremap <Space>s[ <Esc>`<i[<Esc>`>la]<Esc>
vnoremap <Space>s< <Esc>`<i<<Esc>`>la><Esc>
vnoremap <Space>s" <Esc>`<i"<Esc>`>la"<Esc>
vnoremap <Space>s' <Esc>`<i'<Esc>`>la'<Esc>
vnoremap <Space>s` <Esc>`<i`<Esc>`>la`<Esc>

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
  autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>
augroup END
