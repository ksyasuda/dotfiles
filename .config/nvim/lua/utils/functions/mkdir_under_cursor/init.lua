local M = {}
vim.notify = require("notify")

function M.mkdir_under_cursor()
	-- Get the word under the cursor
	local word = vim.fn.expand("<cWORD>")
	-- Remove quotes if present
	word = word:gsub("^[\"']", ""):gsub("[\"']$", "")
	-- Check if directory exists
	local stat = vim.loop.fs_stat(word)
	if not stat then
		-- Create directory (recursive)
		vim.loop.fs_mkdir(word, 493) -- 493 = 0755 in decimal
		vim.notify("Directory created: " .. word, vim.log.levels.INFO)
	else
		vim.notify("Directory already exists: " .. word, vim.log.levels.WARN)
	end
end

function M.setup(opts)
	return M.mkdir_under_cursor
end

return M
