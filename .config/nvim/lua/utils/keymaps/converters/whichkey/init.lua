local M = {}

local whichkey = require("which-key")
vim.notify = require("notify")

---Helper function to add mappings to which-key
---@parm mappings table : List of mappings to add to which-key
---@parm group table : Group to add mappings to (optional)
---@return nil
---@usage addToWhichKey(mappings, group)
---@example addToWhichKey({{key = "n", cmd = "next", mode = "n", desc = "Next Line", group = "Navigation"}, {key = "t", group = "example"})
function M.addToWhichKey(mappings, group)
	local wk_mappings = {}
	if group then
		whichkey.add({ group.key, group = group.group })
	end
	if not mappings and not group then
		vim.notify("Error: Mappings is nil", "error")
		return
	elseif not mappings and group then
		return
	end
	for _, mapping in ipairs(mappings) do
		if not mapping.key or mapping.key == "" then
			vim.notify("Error: Key is empty or nil", "error")
			return
		end

		if not mapping.cmd or mapping.cmd == "" then
			vim.notify("Error: Command is empty or nil for key: " .. mapping.key, "error")
			return
		end

		if not mapping.mode or mapping.mode == "" then
			vim.notify("Error: Mode is empty or nil for key: " .. mapping.key, "error")
			return
		end

		wk_mappings[1] = mapping.key
		wk_mappings[2] = mapping.cmd
		wk_mappings.mode = mapping.mode
		wk_mappings.desc = mapping.desc or "No Description"
		wk_mappings.group = mapping.group or "No Group"
		whichkey.add(wk_mappings)
	end
end

return M
