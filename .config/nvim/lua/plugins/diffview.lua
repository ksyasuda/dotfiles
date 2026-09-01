return {
	"sindrets/diffview.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	keys = {
		{ "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
		{ "<leader>gdf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
		{ "<leader>gdh", "<cmd>DiffviewHistory<cr>", desc = "Repository history" },
		{ "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
		{ "<leader>gdr", "<cmd>DiffviewRefresh<cr>", desc = "Refresh Diffview" },
		{ "<leader>gdt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle files" },
	},
	opts = {
		view = {
			-- Disable the default normal mode mapping for `<tab>`:
			-- ["<tab>"] = false,
			-- Disable the default visual mode mapping for `gf`:
			-- { "x", "gf", false },
		},
		hooks = {
			diff_buf_read = function()
				vim.opt_local.wrap = false
				vim.opt_local.list = false
				vim.opt_local.colorcolumn = { 80 }
			end,
			view_opened = function(view)
				vim.notify(
					("A new %s was opened on tab page %d!"):format(view.class:name(), view.tabpage),
					vim.log.levels.INFO,
					{ timeout = 5000, title = "Diffview" }
				)
			end,
		},
	},
}
