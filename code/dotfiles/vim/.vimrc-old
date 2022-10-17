colorscheme molokai
let g:molokai_original = 1

"python3 from powerline.vim import setup as powerline_setup
"python3 powerline_setup()
"python3 del powerline_setup

set rtp+=/usr/lib/python3.7/site-packages/powerline/bindings/vim/
set laststatus=2
set t_Co=256


syntax on


" -- Spaces & Tabs --

"number of visual spaces per TAB
set tabstop=4

"number of spaces in tab when editing
set softtabstop=4

"tabs are spaces. <TAB> becomes a shortcut for 'insert 4 spaces'
set expandtab


" -- UI Config --

"show line numbers
set number

"show command in bottom bar
set showcmd

"highlight current line
set cursorline

"load filetype-specific indent files
filetype indent on

"visual autocomplete for command menu
set wildmenu

"redraw only when we need to
set lazyredraw

"highlight matching [{()}]
set showmatch


" -- Searching --

"search as characters are entered
set incsearch

" highlight matches
set hlsearch

"turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>


" -- Folding --

"enable folding
set foldenable

"open most folds by default
set foldlevelstart=10

"10 nested fold max
set foldnestmax=10

"space open/closes folds
nnoremap <space> za

"fold based on indent level
set foldmethod=indent


" -- Movement --

"move vertical by visual line
nnoremap j gj
nnoremap k gk

"highlight last inserted text
"nnoremap gV`[v`]


"gundo toggle
nnoremap <F5> :GundoToggle<CR>

"edit vimrc
nnoremap <leader>ev :vsp $MYVIMRC<CR>

"load vimrc bindings
nnoremap <leader>sv :source $MYVIMRC<CR>


