local M = {}

--- Fetches the content from the given URL and then pastes the contents below the current line.
---@param url string The URL to fetch (expects a Git raw URL).
function M.fetch_and_paste(url)
	if not url or url == "" then
		vim.notify("git-paste: No URL provided.", vim.log.levels.WARN)
		return
	end

	-- Use curl to fetch the raw file content
	local result = vim.fn.system({ "curl", "-s", url })

	if vim.v.shell_error ~= 0 then
		vim.notify("git-paste: Failed to fetch content from URL:\n" .. result, vim.log.levels.ERROR)
		return
	end

	-- Split the result into lines. This creates a table with each line.
	local lines = vim.split(result, "\n")

	-- Get the current cursor position. This returns a table {line, col}
	-- Nvim's API for setting lines expects 0-indexed line numbers.
	local pos = vim.api.nvim_win_get_cursor(0)
	-- Insert the fetched lines after the current cursor line.
	-- Since pos[1] is 1-indexed, we use it directly as the insertion index (which is 0-indexed)
	-- when inserting *after* the current line.
	local insert_at = pos[1]
	vim.api.nvim_buf_set_lines(0, insert_at, insert_at, false, lines)

	vim.notify("git-paste: Content pasted successfully", vim.log.levels.INFO)
end

--- Prompts the user for a Git raw URL and then pastes the fetched content.
function M.git_paste_prompt()
	vim.ui.input({ prompt = "Git raw URL: " }, function(input)
		if input then
			M.fetch_and_paste(input)
		else
			vim.notify("git-paste: No URL provided", vim.log.levels.WARN)
		end
	end)
end

--- Sets up the git-paste module.
---
--- The module expects an optional configuration table:
---   { telescope_key = "<leader>pg" } (or any other keymap you prefer)
---
---@param opts table|nil
function M.setup(opts)
	opts = opts or {}
	local telescope_key = opts.telescope_key or "<leader>pg"
	vim.keymap.set("n", telescope_key, M.git_paste_prompt, { desc = "Git Paste: paste content from git raw URL" })
end

return M
