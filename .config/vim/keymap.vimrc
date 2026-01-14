" normal mode
"" display lines downward
nnoremap j gj

"" display lines upward
nnoremap k gk

nnoremap Y y$
nnoremap U <C-r>

nnoremap + <C-a>
nnoremap - <C-x>

nnoremap ; :
nnoremap : ;

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

"" go to unmatched braces/parentheses
nnoremap )} ]}
nnoremap )) ])

nnoremap <Space>h ^
nnoremap <Space>l $
nnoremap <Space>m %

nnoremap [<Space> :<C-u>i<CR><CR>.<CR>
nnoremap ]<Space> :<C-u>a<CR><CR>.<CR>

nnoremap J <C-f>
nnoremap K <C-b>

nmap <Space>a <Plug>(argument)
nnoremap <Plug>(argument) <Nop>
nnoremap <Plug>(argument)r :<C-u>Args<CR>
nnoremap <Plug>(argument)l :<C-u>args<CR>
nnoremap <Plug>(argument)n :<C-u>silent! NextOrFirst<CR><Plug>(argument)
nnoremap <Plug>(argument)p :<C-u>silent! PrevOrLast<CR><Plug>(argument)

nmap <Space>q <Plug>(quickfix)
nnoremap <Plug>(quickfix)n :<C-u>cnext<CR>
nnoremap <Plug>(quickfix)p :<C-u>cprevious<CR>
nnoremap <Plug>(quickfix)k :<C-u>cbefore<CR>
nnoremap <Plug>(quickfix)j :<C-u>cafter<CR>
nnoremap <Plug>(quickfix)w :<C-u>cwindow<CR>
nnoremap <Plug>(quickfix)c :<C-u>cclose<CR>
nnoremap <Plug>(quickfix)o :<C-u>botright copen<CR>
nnoremap <Plug>(quickfix). :<C-u>cgetbuffer<CR>
nnoremap <Plug>(quickfix)f :<C-u>cgetfile<CR>
nnoremap <Plug>(quickfix)h :<C-u>colder<CR>
nnoremap <Plug>(quickfix)l :<C-u>cnewer<CR>
nnoremap <expr> <Plug>(quickfix)H ':<C-u>' . (v:count > 0 ? v:count : '') . 'chistory<CR>'
nnoremap <Plug>(quickfix)e <Cmd>exe 'e' &errorfile<CR>
nnoremap <Plug>(quickfix)i <Cmd>exe 'silent grep! -F ' . g:insert_print_marker<CR>
nnoremap <Plug>(quickfix)r :<C-u>cclose \| botright cw<CR>
"" toggle quickfix
nnoremap <expr> <Plug>(quickfix)t empty(filter(getwininfo(), 'v:val.quickfix')) ? ':botright copen<CR>' : ':cclose<CR>'

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
nnoremap <Plug>(window) <Nop>
nnoremap <Plug>(window)_ <Cmd>split<CR>
nnoremap <Space>- <Cmd>split<CR>
nnoremap <Plug>(window)\ <Cmd>vsplit<CR>
nnoremap <Space>\ <Cmd>vsplit<CR>
nnoremap <Plug>(window)c <C-w>c
nnoremap <Plug>(window)o <C-w>o
nnoremap <Plug>(window)h <C-w>h
nnoremap <Plug>(window)j <C-w>j
nnoremap <Plug>(window)k <C-w>k
nnoremap <Plug>(window)l <C-w>l
nnoremap <Plug>(window)w <C-w>w
nnoremap <Plug>(window)H <Cmd>call SwapWindow('h')<CR>
nnoremap <Plug>(window)J <Cmd>call SwapWindow('j')<CR>
nnoremap <Plug>(window)K <Cmd>call SwapWindow('k')<CR>
nnoremap <Plug>(window)L <Cmd>call SwapWindow('l')<CR>
nnoremap <Plug>(window)<C-h> <Cmd>call MoveWindow('h')<CR>
nnoremap <Plug>(window)<C-j> <Cmd>call MoveWindow('j')<CR>
nnoremap <Plug>(window)<C-k> <Cmd>call MoveWindow('k')<CR>
nnoremap <Plug>(window)<C-l> <Cmd>call MoveWindow('l')<CR>
nnoremap <Plug>(window)f <C-w>f
nnoremap <Plug>(window)F <C-w>F
nnoremap <Plug>(window)gf <C-w>gF
nnoremap <Plug>(window)T <C-w>T
nnoremap <Plug>(window)r <C-w>r
nnoremap <Plug>(window)m <C-w>\|<C-w>_
nnoremap <Plug>(window)= <C-w>=
nnoremap <Plug>(window)<bar> <Cmd>horiz wincmd =<CR>
nnoremap <Plug>(window)> <C-w>>
nnoremap <Plug>(window)< <C-w><
nnoremap <Plug>(window)+ <C-w>+
nnoremap <Plug>(window)- <C-w>-
"" copy and paste a window
nnoremap <Plug>(window)y <Cmd>let @w=expand('%')<CR>
nnoremap <Plug>(window)p <Cmd>exe 'e ' . @w<CR>
nnoremap <Plug>(window)t <Cmd>tab split<CR>
nnoremap <Plug>(window)<CR> <Cmd>ToggleFocusMax<CR>
nnoremap <Left> <C-w>h
nnoremap <Down> <C-w>j
nnoremap <Up> <C-w>k
nnoremap <Right> <C-w>l

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

nnoremap <plug>(cgl)  <Nop>
nnoremap g; g;<plug>(cgl)
nnoremap g, g,<plug>(cgl)
nnoremap <plug>(cgl); g;<plug>(cgl)
nnoremap <plug>(cgl), g,<plug>(cgl)

nmap <C-f> <Plug>(file)
nnoremap <Plug>(file)<C-y> <Cmd>CopyFilename<CR>

nmap <Space>p <Plug>(pin)
nnoremap <Plug>(pin) <Nop>
nnoremap <Plug>(pin)p <Cmd>Pin<CR><Cmd>redraw!<CR>
nnoremap <Plug>(pin)b <Cmd>BackToPin<CR>

nnoremap <Space><Space>b <Cmd>exe 'e .local/bookmarks.txt'<CR>
nnoremap <Space><Space>m <Cmd>tabnew .local/memo.md<CR>

nnoremap <C-s> :<C-u>update<CR>

"" move cursor to center/top/bottom
nmap zz zz<sid>(z1)
nnoremap <script> <sid>(z1)z zt<sid>(z2)
nnoremap <script> <sid>(z2)z zb<sid>(z3)
nnoremap <script> <sid>(z3)z zz<sid>(z1)

"" not to yunk
nnoremap x "_x
nnoremap X "_X
nnoremap s "_s
nnoremap S "_S

"" format all lines
nnoremap <Space>= gg=G``

"" yank all lines
nnoremap <Space>y ggyG``

"" select all
nnoremap <Space>v ggVG

"" delete all
nnoremap <Space>d ggdG

"" move to end after pasting
nnoremap <silent> p p`]

"" select last pasted
nnoremap gpv `[v`]

nnoremap <Space>o <Cmd>call append(line('.'),'')<CR>
nnoremap <Space>O <Cmd>call append(line('.')-1,'')<CR>

nnoremap <Space>; A;<Esc>
nnoremap <Space>, A,<Esc>

nnoremap <M-z> :<C-u>set wrap!<CR>

" insert mode
inoremap jk <Esc>
inoremap ｊｋ <Esc>
inoremap <C-l> <Del>
inoremap <C-z> <C-o>u
inoremap <C-y> <C-o><C-r>
inoremap <C-v>u <C-r><C-r>=nr2char(0x)<Left>
inoremap <C-s> <Esc>:<C-u>update<CR>gi
inoremap <Left> <C-g>U<Left>
inoremap <Right> <C-g>U<Right>
inoremap <CR> <C-g>u<CR>
inoremap <C-d> <C-k>

imap <C-f> <Plug>(i_file)
inoremap <Plug>(i_file) <Nop>
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

vnoremap <Space>h ^
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

" depends on FileType
augroup FileTypeMap
  autocmd!
  autocmd FileType help nnoremap <buffer> <CR> <C-]>
augroup END
