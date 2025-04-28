" Realce de sintaxe
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "python",
  highlight = { enable = true },
  indent = { enable = true }
}
EOF

