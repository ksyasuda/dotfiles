return {
	"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	config = function()
		-- lsp_lines
		vim.diagnostic.config({ virtual_text = false })
		-- --
		vim.keymap.set("", "<Leader>tl", require("lsp_lines").toggle, { desc = "Toggle lsp_lines" })
	end,
}
