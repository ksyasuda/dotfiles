local M = {}

function M.setup()
	require("which-key").add({
		{ "<leader>a", group = "AnyJump" },
		{ "<leader>b", group = "Buffers" },
		{ "<leader>c", group = "Code" },
		{ "<leader>ca", group = "Code actions" },
		{ "<leader>cc", group = "Calls" },
		{ "<leader>cL", group = "LSP" },
		{ "<leader>cP", group = "Python" },
		{ "<leader>C", group = "CodeCompanion" },
		{ "<leader>f", group = "Find" },
		{ "<leader>g", group = "Git" },
		{ "<leader>gd", group = "Diffview" },
		{ "<leader>h", group = "Help" },
		{ "<leader>i", group = "Image" },
		{ "<leader>j", group = "AnyJump" },
		{ "<leader>n", group = "Navigation and notifications" },
		{ "<leader>N", group = "Noice" },
		{ "<leader>o", group = "Open" },
		{ "<leader>p", group = "Paste" },
		{ "<leader>pg", group = "Paste Git raw" },
		{ "<leader>s", group = "Search" },
		{ "<leader>t", group = "Terminal" },
		{ "<leader>T", group = "Telescope" },
		{ "<leader>w", group = "Workspace" },
		{ "<leader>x", group = "Executable bit" },
		{ "<leader>y", group = "System clipboard" },
	})
end

return M
