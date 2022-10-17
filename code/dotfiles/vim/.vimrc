" -- Theme --
colorscheme molokai
let g:molokai_original = 1

" -- Plugins by vim-plug: https://github.com/junegunn/vim-plug --
call plug#begin()
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jistr/vim-nerdtree-tabs'
call plug#end()

" -- nerdtree --
nmap <silent> <special> <F2> :NERDTreeToggle<RETURN>

" -- vim-airlinesettings --
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'

" -- netrw ---
let g:netrw_banner = 0

" -- fzf ---
let g:fzf_preview_window = ['right,50%', 'ctrl-/']

" -- Movement --
noremap <C-l> <C-b>
noremap <C-h> <C-f>
noremap <C-j> <C-d>
noremap <C-k> <C-u>
map gn :bn<cr>
map gb :bp<cr>
map gd :bd<cr> 
" -- Editing --
set backspace=indent,eol,start

" -- Spaces & Tabs --
set tabstop=4
set softtabstop=4
set expandtab

" -- UI Config --
syntax on
set number
set showcmd
set cursorline
set showmatch
set lazyredraw
filetype indent on

" -- Searching --
set incsearch
set hlsearch
nnoremap <leader><space> :nohlsearch<CR>

" -- Folding --
set foldenable
set foldmethod=indent
set foldlevelstart=10
set foldnestmax=10
nnoremap <space> za

" -- Misc Maps --
"edit vimrc
nnoremap <leader>ev :vsp $MYVIMRC<CR>
"load vimrc bindings
nnoremap <leader>sv :source $MYVIMRC<CR>

