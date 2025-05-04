return {
	url = "https://gitea.suda.codes/sudacode/odis",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"neovim/nvim-lspconfig",
	},
	opts = {
		opts = {
			display = {
				default_mode = "vsplit",
				picker = true,
				float = {
					maxwidth = 80,
					maxheight = 40,
					border = "rounded",
					title = true,
					style = "minimal",
					auto_focus = true,
					anchor = "bottom_right",
					offset = { row = -2, col = -2 },
				},
				window = {
					width = 0.4,
					height = 0.25,
					position = "bottom|right",
					floating = false,
					border = "none",
				},
			},
			integrations = {
				treesitter = {
					enabled = true, -- Enable Treesitter integration
					highlight = true, -- Enable syntax highlighting
					langs = { -- Language mapping for different doc types
						lsp = "markdown",
						man = "man",
						help = "vimdoc",
					},
				},
			},
			sources = {
				lsp = { enabled = true },
				vim = { enabled = true },
				man = { enabled = true },
			},
			priority = { "LSP", "Vim", "Man" },
			mappings = {
				close = "<leader>dc",
			},
		},
	},
}
