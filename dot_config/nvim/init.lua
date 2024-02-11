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
require("lazy").setup("plugins") -- plugins are stored in plugins module
--[[ end:plugin ]]--
--------------------

-----------------
--[[ options ]]--
--- theme
vim.o.termguicolors = true
vim.o.title = true
vim.o.background = 'dark' -- or 'light'
--vim.cmd.colorscheme 'catppuccin-mocha'
vim.cmd.colorscheme 'solarized-osaka-night'
-- vim.cmd.colorscheme 'kanagawa-dragon'

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
vim.keymap.set('v', '.', ':normal .<CR>') -- perform dot commands over visual blocks
-- moving betwee windows
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
-- resize
vim.keymap.set("n", "<C-Up>", ":resize -4<CR>")
vim.keymap.set("n", "<C-Down>", ":resize +4<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -4<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +4<CR>")
--[[ end:remoaps ]]--


-- vim.keymap.set("n", "<leader>n", ":Neotree toggle<CR>")


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
]])
