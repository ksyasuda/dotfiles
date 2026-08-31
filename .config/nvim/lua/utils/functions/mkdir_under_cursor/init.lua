local M = {}

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
	local stat = vim.uv.fs_stat(word)
	if not stat then
		if vim.fn.mkdir(word, "p") == 1 then
			vim.notify("Directory created: " .. word, vim.log.levels.INFO)
		else
			vim.notify("Failed to create directory: " .. word, vim.log.levels.ERROR)
		end
	else
		vim.notify("Directory already exists: " .. word, vim.log.levels.WARN)
	end
end

return M
