set termguicolors



" Linha = LuaLine
lua << END
function setLualineTheme(theme_name)
  require('lualine').setup {
    options = {
      theme = theme_name,
      -- Outras opções de configuração
      section_separators = '',
      component_separators = ''
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch'},
      lualine_c = {'filename'},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'}
    },
  }
end

-- Chamadas diretas
if vim.fn.filereadable(vim.fn.expand("~/.cache/wal/colors-wal.vim")) == 1 then
  setLualineTheme("pywal")
else
  setLualineTheme("palenight")
end
END




" Tema
if filereadable(expand("~/.cache/wal/colors-wal.vim"))
    source ~/.cache/wal/colors-wal.vim
    colorscheme pywal
    execute 'highlight LineNr guibg=NONE guifg=' . color2
    execute 'highlight CursorLineNr guifg=' . color3 . ' guibg=NONE'
    execute 'highlight ColorColumn guibg=' . color2


else
    let g:catppuccin_flavour = "mocha"  " Escolha 'latte', 'frappe', 'macchiato' ou 'mocha'
    colorscheme catppuccin

    " Background
    highlight Normal guibg=#191919 ctermbg=NONE

    " Cores dos números das linhas
    highlight LineNr guibg=NONE guifg=#888888
    " Linha do cursor
    set cursorline
    highlight CursorLineNr guifg=#AAAAAA guibg=NONE
    highlight CursorLine guibg=NONE
endif




