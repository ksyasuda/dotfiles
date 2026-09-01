local M = {}

local map = vim.keymap.set

function M.setup()
	map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
	map("n", "n", "nzzzv", { desc = "Next search result and center" })
	map("n", "N", "Nzzzv", { desc = "Previous search result and center" })
	map("x", "<leader>pp", '"_dP', { desc = "Paste without yanking" })
	map("v", "<", "<gv", { desc = "Reselect after indent" })
	map("v", ">", ">gv", { desc = "Reselect after indent" })
	map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
	map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

	map("n", "<C-J>", "<cmd>bnext<cr>", { desc = "Next buffer" })
	map("n", "<C-K>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
	map("n", "<leader>bk", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
	map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
	map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

	map("n", "<leader>x", "<cmd>!chmod +x %<cr>", { desc = "Make file executable" })
	map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
	map("n", "<leader>sc", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
	map({ "n", "v" }, "<leader>m", require("utils.functions.mkdir_under_cursor").mkdir_under_cursor, {
		desc = "Create directory from text",
	})
	map("n", "<leader>pg", require("utils.functions.git_paste").git_paste_prompt, {
		desc = "Paste content from Git raw URL",
	})

	map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
	map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
	map("n", "<leader>wl", function()
		vim.print(vim.lsp.buf.list_workspace_folders())
	end, { desc = "List workspace folders" })
end

return M
