" Inicializar o VimPlug
call plug#begin('~/.config/nvim/plugged')

" Exemplos de plugins (adicione os que desejar)
Plug 'preservim/nerdtree'          " Navegador de arquivos
"Plug 'tpope/vim-fugitive'          " Git integration
"Plug 'junegunn/fzf.vim'            " Fuzzy finder
Plug 'catppuccin/nvim', {'as': 'catppuccin'}
Plug 'nvim-lualine/lualine.nvim'
Plug 'AlphaTechnolog/pywal.nvim', { 'as': 'pywal' }
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Finalizar configuração
call plug#end()

" Executar PlugInstall e PlugUpdate automaticamente apenas no VimEnter inicial
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | source $MYVIMRC | endif

