return {
--   {
--     "ellisonleao/gruvbox.nvim",
--     lazy = false,
--     priority = 1000,
--   },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
			color_overrides = {
				mocha = {
					base = "#080808",
					mantle = "#080808",
					crust = "#080808",
				},
			},
    },
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    priority = 1000,
    opts = { theme = 'neo' }
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {'nvim-tree/nvim-web-devicons' },
    opts = function()
      local lualine_solarized = require('lualine.themes.solarized_dark')
      lualine_solarized.normal.b = { fg = lualine_solarized.normal.c.fg, bg = lualine_solarized.normal.c.bg, gui = 'bold' }
      return {
        options = {
          theme = lualine_solarized,
          section_separators = '',
          component_separators = ''
        },
        sections = {
          lualine_b = {'branch', 'diff'},
          lualine_c = {{'filename', path = 1}},
          lualine_x = {
            'diagnostics',
            'encoding',
            {'fileformat', symbols = {unix = '[unix]', dos = '[dos]', mac ='[mac]'}},
            'filetype'
          }
        }
      }
    end
  },
}
