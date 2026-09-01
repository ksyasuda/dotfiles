local M = {}

local map = vim.keymap.set

function M.setup()
	map("n", "gA", vim.lsp.buf.code_action, { desc = "Code action" })
	map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Definitions" })
	map("n", "gDc", "<cmd>Telescope lsp_implementations<cr>", { desc = "Implementations" })
	map("n", "gDf", "<cmd>Telescope lsp_definitions<cr>", { desc = "Definitions" })
	map("n", "gF", "<cmd>edit <cfile><cr>", { desc = "Edit file under cursor" })
	map("n", "gT", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Type definitions" })
	map("n", "gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Blame line" })
	map("n", "<leader>gb", "<cmd>Gitsigns blame<cr>", { desc = "Git blame" })
	map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", { desc = "Implementations" })
	map("n", "gj", "<cmd>Telescope jumplist<cr>", { desc = "Jumplist" })
	map("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
	map("n", "gs", vim.lsp.buf.signature_help, { desc = "Signature help" })
	map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
	map("n", "<leader>ch", vim.lsp.buf.signature_help, { desc = "Signature help" })
	map("n", "<leader>cR", vim.lsp.buf.rename, { desc = "Rename" })
	map("n", "<leader>cr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
	map("n", "<leader>cs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document symbols" })
	map("n", "<leader>ct", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Type definitions" })
	map("n", "<leader>cw", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "Workspace symbols" })
	map("n", "<leader>ci", "<cmd>Telescope lsp_implementations<cr>", { desc = "Implementations" })
	map("n", "<leader>cci", "<cmd>Telescope lsp_incoming_calls<cr>", { desc = "Incoming calls" })
	map("n", "<leader>cco", "<cmd>Telescope lsp_outgoing_calls<cr>", { desc = "Outgoing calls" })
	map("n", "<leader>cd", "<cmd>Telescope diagnostics theme=dropdown layout_config={width=0.8}<cr>", {
		desc = "Diagnostics",
	})
	map("n", "<leader>cDs", "<cmd>Telescope diagnostics theme=dropdown layout_config={width=0.8}<cr>", {
		desc = "Diagnostics",
	})
	map("n", "<leader>cDn", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { desc = "Next diagnostic" })
	map("n", "<leader>cDp", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { desc = "Previous diagnostic" })
	map("n", "<leader>cl", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })
	map("n", "<leader>Clr", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })
	map("n", "<leader>cPs", function()
		vim.cmd("!pyright --createstub " .. vim.fn.expand("<cword>"))
	end, { desc = "Generate Python stub" })
end

return M
