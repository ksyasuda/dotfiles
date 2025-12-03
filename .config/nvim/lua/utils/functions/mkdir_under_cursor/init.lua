local M = {}
vim.notify = require("notify")

function M.mkdir_under_cursor()
	local word

	-- Check if in visual mode
	if vim.fn.mode():match("[vV]") then
		-- Get visual selection
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")
		local line = vim.fn.getline(start_pos[2])
		word = line:sub(start_pos[3], end_pos[3])
	else
		-- Get word under cursor
		word = vim.fn.expand("<cWORD>")
	end

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
