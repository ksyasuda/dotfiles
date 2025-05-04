return {
	"sindrets/diffview.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = {
		view = {
			-- Disable the default normal mode mapping for `<tab>`:
			-- ["<tab>"] = false,
			-- Disable the default visual mode mapping for `gf`:
			-- { "x", "gf", false },
		},
	},
	hooks = {
		diff_buf_read = function(bufnr)
			-- Change local options in diff buffers
			vim.opt_local.wrap = false
			vim.opt_local.list = false
			vim.opt_local.colorcolumn = { 80 }
		end,
		view_opened = function(view)
			require("notify").notify(
				("A new %s was opened on tab page %d!"):format(view.class:name(), view.tabpage),
				"info",
				{ timeout = 5000, title = "Diffview" }
			)
		end,
	},
}
