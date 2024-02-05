
" Disables automatic commenting on newline:
" autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Goyo plugin makes text more readable when writing prose:
map <leader>g :Goyo \| set bg=dark \| set linebreak<CR>
" Spell-check set to <leader>o, 'o' for 'orthography':
map <leader>o :setlocal spell! spelllang=en_us<CR>
" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.

" Nerd tree
" map <leader>n :NERDTreeToggle<CR>
" let NERDTreeShowHidden=1
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" if has('nvim')
" 	let NERDTreeBookmarksFile = stdpath('data') . '/NERDTreeBookmarks'
" else
" 	let NERDTreeBookmarksFile = '~/.vim' . '/NERDTreeBookmarks'
" endif


" Replace ex mode with gq
map Q gq

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<CR>
" Replace all is aliased to S.
nnoremap S :%s//g<Left><Left>

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :set hlsearch!<cr>

" Fast saving
nmap <leader>w :w!<CR>

autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%" || true

" Automatically deletes all trailing whitespace and newlines at end of file on save.
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritePre * %s/\n\+\%$//e

" Turns off highlighting on the bits of code that are changed, so the line that is changed is highlighted but the actual text that has changed stands out on the line and is readable.
if &diff
	highlight! link DiffText MatchParen
endif

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
