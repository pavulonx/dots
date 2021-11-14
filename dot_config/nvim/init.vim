let mapleader =","

if ! filereadable(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim"'))
	echo "Downloading junegunn/vim-plug to manage plugins..."
	silent !mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim
	autocmd VimEnter * PlugInstall
endif

call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/fzf.vim'
Plug 'jreybert/vimagit'
Plug 'vimwiki/vimwiki'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-commentary'
Plug 'lifepillar/vim-solarized8'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': 'bash install.sh'}
" Plug 'ap/vim-css-color' " disabled because of https://github.com/ap/vim-css-color/issues/139
call plug#end()

source ~/.config/nvim/coc.vim

"""""" theme
colorscheme solarized8
let g:solarized_statusline=''
let g:airline_theme='solarized_flood'
set termguicolors
set title
set bg=dark

set autoread " autoread file changed fromthe outside
set lazyredraw
set mouse=a
set clipboard+=unnamedplus
set wildmenu " Turn on the Wild menu
set wildmode=longest,list,full "Enable autocompletion:

set encoding=utf-8
set number relativenumber
set noshowmode " If in Insert, Replace or Visual mode put a message on the last line.
set history=1000
set so=7 " Set 7 lines to the cursor - when moving vertically using j/k
set ruler
"set foldcolumn=1 " Add a bit extra margin to the left
set cursorline " highlight line
"set cursorcolumn " highlight column
set splitbelow splitright
"set showtabline=2

set hlsearch " Highlight search results
set ignorecase " Ignore case when searching
set smartcase " When searching try to be smart about cases
set incsearch " Makes search act like search in modern browsers

""""" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

""""" TAB & text settings
set expandtab " Use spaces instead of tabs
set smarttab " Be smart when using tabs ;)
" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2
" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines


" Some basics:
nnoremap c "_c
set nocompatible
filetype plugin on
filetype indent on
syntax on

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
" Perform dot commands over visual blocks:
vnoremap . :normal .<CR>

map <leader>f :Files<CR>
" Goyo plugin makes text more readable when writing prose:

map <leader>g :Goyo \| set bg=dark \| set linebreak<CR>
" Spell-check set to <leader>o, 'o' for 'orthography':
map <leader>o :setlocal spell! spelllang=en_us<CR>
" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.

" Nerd tree
map <leader>n :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
if has('nvim')
	let NERDTreeBookmarksFile = stdpath('data') . '/NERDTreeBookmarks'
else
	let NERDTreeBookmarksFile = '~/.vim' . '/NERDTreeBookmarks'
endif

" Shortcutting split navigation, saving a keypress:
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Replace ex mode with gq
map Q gq

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<CR>
" Replace all is aliased to S.
nnoremap S :%s//g<Left><Left>

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :set hlsearch!<cr>
" Check file in shellcheck:
map <leader>s :!clear && shellcheck -x %<CR>
" Compile document, be it groff/LaTeX/markdown/etc.
map <leader>c :w! \| !compiler "<c-r>%"<CR>
" Save file as sudo on files that require root permission
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!
" Open corresponding .pdf/.html or preview
map <leader>p :!opout <c-r>%<CR><CR>

" Fast saving
nmap <leader>w :w!<CR>

" Ensure files are read as what I want:
let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown','.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
map <leader>v :VimwikiIndex
let g:vimwiki_list = [{'path': '~/vimwiki', 'syntax': 'markdown', 'ext': '.md'}]

autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%"

" Automatically deletes all trailing whitespace and newlines at end of file on save.
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritePre * %s/\n\+\%$//e

" Run xrdb whenever Xdefaults or Xresources are updated.
autocmd BufRead,BufNewFile xresources,xdefaults set filetype=xdefaults
autocmd BufWritePost Xresources,Xdefaults,xresources,xdefaults !xrdb %
" Compile xmonad.hs on change
"autocmd BufWritePost xmonad.hs !xmonad --recompile && xmonad --restart

" Turns off highlighting on the bits of code that are changed, so the line that is changed is highlighted but the actual text that has changed stands out on the line and is readable.
if &diff
	highlight! link DiffText MatchParen
endif

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Close all the buffers
map <leader>ba :bufdo bd<cr>
map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>
" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext
" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()
" Opens a new tab with the current buffer's path
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>
