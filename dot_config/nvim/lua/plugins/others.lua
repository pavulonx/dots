local vim = vim

return {
  {'nvim-telescope/telescope.nvim', tag = '0.1.5', dependencies = {'nvim-lua/plenary.nvim' }},
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'neovim/nvim-lspconfig',
  'tpope/vim-surround',
  { 'farmergreg/vim-lastplace', lazy = false}, -- return to last edit position when opening files
  -- 'preservim/nerdtree',
--------  {
--------    "nvim-neo-tree/neo-tree.nvim",
--------    branch = "v3.x",
--------    dependencies = {
--------      "nvim-lua/plenary.nvim",
--------      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
--------      "MunifTanjim/nui.nvim",
--------      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
--------    },
--------    opts = {
--------      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
--------      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
--------      filesystem = {
--------        filtered_items = {
--------          visible = true,
--------          show_hidden_count = true,
--------          hide_dotfiles = false,
--------          hide_gitignored = false,
--------          never_show = {},
--------        },
--------      }
--------    }
--------  },
  'junegunn/goyo.vim',
  -- " Plug 'junegunn/fzf.vim'
  'jreybert/vimagit',
  'vimwiki/vimwiki',
--   { "ellisonleao/gruvbox.nvim",
--   lazy = false,
--   priority = 1000,
--   },
  'tpope/vim-commentary',
  -- 'airblade/vim-gitgutter',
  'tpope/vim-fugitive',
  -- { 'neoclide/coc.nvim', branch = 'release' },
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
  'luckasRanarison/tree-sitter-hyprlang',
  -- " Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': 'bash install.sh'}
  -- " Plug 'ap/vim-css-color' " disabled because of https://github.com/ap/vim-css-color/issues/139
}
