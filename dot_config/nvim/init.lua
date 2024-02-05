local vim = vim -- to make LSP shut up  TODO: change vim to just v

vim.g.mapleader = " "
vim.g.maploaclleader = " "

----------------
--[[ plugin ]]--
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  {'nvim-telescope/telescope.nvim', tag = '0.1.5', dependencies = {'nvim-lua/plenary.nvim' }},
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'neovim/nvim-lspconfig',
  'tpope/vim-surround',
  'preservim/nerdtree',
  'junegunn/goyo.vim',
-- " Plug 'junegunn/fzf.vim'
  'jreybert/vimagit',
  'vimwiki/vimwiki',
  {
    'lifepillar/vim-solarized8',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme solarized8")
    end
  },
  {
    'nvim-lualine/lualine.nvim',
     dependencies = {'nvim-tree/nvim-web-devicons' }
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
  },
  'tpope/vim-commentary',
  'airblade/vim-gitgutter',
  'tpope/vim-fugitive',
  { 'neoclide/coc.nvim', branch = 'release' },
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
 'luckasRanarison/tree-sitter-hyprlang',
-- " Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': 'bash install.sh'}
-- " Plug 'ap/vim-css-color' " disabled because of https://github.com/ap/vim-css-color/issues/139
}
require("lazy").setup(plugins) --, { defaults = { lazy = false } } )
--[[ end:plugin ]]--
--------------------

-----------------
--[[ lualine ]]--
local lualine_solarized = require('lualine.themes.solarized_dark')
lualine_solarized.normal.b = { fg = lualine_solarized.normal.c.fg, bg = lualine_solarized.normal.c.bg, gui = 'bold' }
require("lualine").setup {
  options = {
    theme = lualine_solarized,
    section_separators = '',
    component_separators = ''
  },
  sections = {
    lualine_b = {'branch', 'diff'},
    lualine_x = {
      'diagnostics',
      'encoding',
      {'fileformat', symbols = {unix = '[unix]', dos = '[dos]', mac ='[mac]'}},
      'filetype'
    }
  }
  -- TODO: add tabline
}
--[[ end:lualine ]]--
---------------------


--- automaticaly exec which-key -- TODO: if not needed remoe this and just command :WhichKey
require("which-key").setup {}


-----------------
--[[ options ]]--
--- theme
vim.o.termguicolors = true
vim.o.title = true
vim.o.bg = 'dark'

-- numbers
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.signcolumn = 'yes'

-- vim.o,showmode = true -- " If in Insert, Replace or Visual mode put a message on the last line.
vim.o.cursorline = true

vim.o.history = 1000
vim.o.undofile = true

vim.o.splitbelow = true
vim.o.splitright = true

vim.o.scrolloff = 7
vim.o.ruler = true

vim.o.autoread = true
vim.o.lazyredraw = true

vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"

vim.o.wildmenu = true -- Turn on the Wild menu
vim.o.wildmode = 'longest,list,full'  -- "Enable autocompletion:

-- search
vim.o.hlsearch = true --" Highlight search results
vim.o.ignorecase = true --" Ignore case when searching
vim.o.smartcase = true --" When searching try to be smart about cases
vim.o.incsearch = true --" Makes search act like search in modern browsers

-- spacing, indent, wrap
vim.o.expandtab = true
vim.o.smarttab = true

vim.o.shiftwidth = 2
vim.o.tabstop = 2

vim.o.linebreak = true
vim.o.textwidth = 500

vim.o.autoindent = true
vim.o.smartindent = true
vim.o.wrap = true


---- backup stuff - turn off to improve speed
-- vim.o.backup = false
-- vim.o.wb = false
-- vim.o.swapfile = false


--------- https://linuxhandbook.com/vim-auto-complete/
------- <C-x> <C-l> - complete line ?????

--[[ end:options ]]--
---------------------

--[[ remoaps ]]--
vim.keymap.set('n', 'c', '"_c') -- in normal mode CHANGE (c) puts changed word into black hole register (does not copy to cp)
--[[ end:remoaps ]]--




require("mason").setup()
require("mason-lspconfig").setup()

local lspconfig = require("lspconfig")
lspconfig.lua_ls.setup {}


-------------------
--[[ telescope ]]--
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
--[[ end:telescope ]]--
-----------------------



----- sourcing old files -- TODO: remove
vim.cmd([[
source ~/.config/nvim/init-legacy.vim
source ~/.config/nvim/coc.vim
]])
