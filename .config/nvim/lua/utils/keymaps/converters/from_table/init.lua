local M = {}
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

function M.set_keybindings(bindings)
	for _, binding in ipairs(bindings) do
		map(binding.mode, binding.key, binding.cmd, binding.opts or opts)
	end
	return bindings
end

return M
