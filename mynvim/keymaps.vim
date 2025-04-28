" Remapear tecla leader para espaço
let mapleader = " "

" Definir uma combinação de teclas para recarregar o init.vim
nnoremap <leader>r :source $MYVIMRC<CR>

" Mapear Ctrl+C, Ctrl+V, Ctrl+X
nnoremap <C-c> "+y
vnoremap <C-c> "+y
nnoremap <C-v> "+p
vnoremap <C-v> "+p
nnoremap <C-x> "+d
vnoremap <C-x> "+d

" Nerdtree
nnoremap <C-n> :NERDTreeToggle<CR>

