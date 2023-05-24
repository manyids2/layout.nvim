local plugins = {
	-- basics
	"nvim-lua/plenary.nvim",

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "markdown" },
				auto_install = true,
			})
		end,
	},
	"nvim-treesitter/nvim-treesitter-textobjects",
	{
		"nvim-treesitter/playground",
		config = function()
			require("nvim-treesitter.configs").setup({
				playground = {
					enable = true,
					disable = {},
					updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
					persist_queries = false, -- Whether the query persists across vim sessions
					keybindings = {
						toggle_query_editor = "o",
						toggle_hl_groups = "i",
						toggle_injected_languages = "t",
						toggle_anonymous_nodes = "a",
						toggle_language_display = "I",
						focus_language = "f",
						unfocus_language = "F",
						update = "R",
						goto_node = "<cr>",
						show_help = "?",
					},
				},
			})
		end,
	},

	-- telescope
	"nvim-telescope/telescope.nvim",

	-- usability
	"MunifTanjim/nui.nvim",
	"folke/which-key.nvim",
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			views = {
				cmdline_popup = {
					border = {
						style = "none",
						padding = { 2, 3 },
					},
					filter_options = {},
					win_options = {
						winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
					},
				},
			},
		},
	},

	-- themes
	"rktjmp/lush.nvim",
	"catppuccin/nvim",
	"bluz71/vim-moonfly-colors",
	"bluz71/vim-nightfly-colors",
	"folke/tokyonight.nvim",
	"aktersnurra/no-clown-fiesta.nvim",
	"nyoom-engineering/oxocarbon.nvim",
	"mcchrish/zenbones.nvim",
	"nvim-tree/nvim-web-devicons",
	"EdenEast/nightfox.nvim",

	-- neotree, bufferline?
	{
		"nvim-neo-tree/neo-tree.nvim",
		opts = {
			filesystem = { filtered_items = { hide_by_pattern = { "*.lua", "Makefile" } } },
		},
	},
	{
		"akinsho/bufferline.nvim",
		opts = {
			options = {
				buffer_close_icon = "",
				separator_style = "slant",
			},
		},
	},

	-- Dev
	{ dir = "/home/x/fd/code/nvim-stuff/layout.nvim" },

	-- Release
	-- { "manyids2/layout.nvim" },
}

require("lazy").setup(plugins)
