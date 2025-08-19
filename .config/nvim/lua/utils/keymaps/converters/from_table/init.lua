local M = {}
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

--- Set keybindings from a table of mappings.
--- @param bindings table A list of keybinding mappings.
--- Each mapping should be a table with the following keys:
--- - mode: string, the mode in which the keybinding applies (e.g., 'n', 'i', 'v').
--- - key: string, the key to bind.
--- - cmd: string, the command to execute when the key is pressed.
--- - opts: table, optional, additional options for the keybinding (default:
function M.set_keybindings(bindings)
	for _, binding in ipairs(bindings) do
		map(binding.mode, binding.key, binding.cmd, binding.opts or opts)
	end
	return bindings
end

return M
