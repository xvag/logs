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
Plug 'hashivim/vim-terraform'
call plug#end()

" -- Fkeys --
nnoremap <silent> <F1> :NERDTreeToggle<CR>
nnoremap <silent> <F2> :Files<CR>
nnoremap <silent> <F3> :Lines<CR>
nnoremap <silent> <F4> :BLines<CR>

" -- vim-airlinesettings --
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_splits = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#tab_nr_type = 1

" -- netrw ---
let g:netrw_banner = 0

" -- fzf ---
"let g:fzf_layout = { 'down': '~40%' }
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
set hidden
set backspace=indent,eol,start

" -- Spaces & Tabs --
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" -- UI Config --
set mouse=a
syntax on
set number
set showcmd
set cursorline
set showmatch
set lazyredraw
filetype indent on

" -- Searching --
nnoremap <silent> <Leader>f :Rg<CR>
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case --hidden ".shellescape(<q-args>), 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

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
"set it to interactive in order to load .bashrc
set shellcmdflag=-ic
" Zoom in/out of a window
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=
