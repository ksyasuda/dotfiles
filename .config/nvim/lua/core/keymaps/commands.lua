local M = {}

function M.setup()
	vim.api.nvim_create_user_command("Config", "edit ~/.config/nvim", { desc = "Edit Neovim configuration" })
	vim.api.nvim_create_user_command(
		"Keymaps",
		"edit ~/.config/nvim/lua/core/keymaps/init.lua",
		{ desc = "Edit keymaps" }
	)
	vim.api.nvim_create_user_command(
		"Hypr",
		"edit ~/.config/hypr/hyprland.conf",
		{ desc = "Edit Hyprland configuration" }
	)

	vim.keymap.set("", "<Leader>tl", function()
		vim.diagnostic.enable(not vim.diagnostic.is_enabled())
	end, { desc = "Toggle diagnostics" })
end

return M
