local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- useful module packer
  { 'echasnovski/mini.nvim', branch = 'stable' },

  -- ai completion
	"github/copilot.vim",

  -- extension api
	"nvim-lua/popup.nvim", -- An implementation of the Popup API from vim in Neovim
	"nvim-lua/plenary.nvim", -- Useful lua functions used ny lots of plugins

	-- appearance
  {"lukas-reineke/indent-blankline.nvim", main="ibl", opt={} },
	{
		"norcalli/nvim-colorizer.lua",
		event = "BufReadPre",
	},

	-- theme
	"shatur/neovim-ayu",
	"rebelot/kanagawa.nvim",
	"folke/tokyonight.nvim",
	"NLKNguyen/papercolor-theme",
	"EdenEast/nightfox.nvim",

	-- which key
	{
		"folke/which-key.nvim",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 200
		end,
	},

	-- cmp
	{
		"hrsh7th/nvim-cmp",
		event = "VimEnter",
	},
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"saadparwaiz1/cmp_luasnip", -- snippet completions
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-nvim-lua",

	{
		"L3MON4D3/LuaSnip",
		event = "VimEnter",
		build = "make install_jsregexp",
	},
	"rafamadriz/friendly-snippets", -- a bunch of snippets to use

	-- telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.2",
	},
	"nvim-telescope/telescope-media-files.nvim",
	"benfowler/telescope-luasnip.nvim",

	-- lsp
	"neovim/nvim-lspconfig",
	{
		"williamboman/mason.nvim", -- simple to use language server installer
		event = { "BufReadPre", "VimEnter" },
		build = ":MasonUpdate",
	},
	"williamboman/mason-lspconfig.nvim", -- simple to use language server installer
	"jose-elias-alvarez/null-ls.nvim", -- LSP diagnostics and code actions

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
	},
	"p00f/nvim-ts-rainbow",
	"nvim-treesitter/playground",
	"nvim-treesitter/nvim-treesitter-context",

	-- git
	"lewis6991/gitsigns.nvim",

	-- file explorer
	"nvim-tree/nvim-tree.lua",
	"nvim-tree/nvim-web-devicons",

	-- bufferline
	{ "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" },

	-- toggleterminal
	-- {"akinsho/toggleterm.nvim", event="VeryLazy"},

	-- file info
	"nvim-lualine/lualine.nvim",
	"simrat39/symbols-outline.nvim",

	-- edit
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},
	{
		"phaazon/hop.nvim",
		branch = "v2",
		config = function()
			require("hop").setup({})
		end,
	},
  'windwp/nvim-autopairs',
	"windwp/nvim-ts-autotag",

	-- Debugger
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
			},
			{ "theHamsta/nvim-dap-virtual-text" },
			{
				"nvim-telescope/telescope-dap.nvim",
			},
			{ "jbyuki/one-small-step-for-vimkind" },
		},
	},

	-- my functions
	{ "enigmaiiiiiiii/mini-functions.nvim", event = "VeryLazy" },
})
