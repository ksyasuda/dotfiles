local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- {{{ Restore cursor position
local restore_cursor = augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
	group = restore_cursor,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})
-- }}}

-- {{{ Open help and man in vertical split
local help_config = augroup("HelpConfig", { clear = true })
autocmd("FileType", {
	group = help_config,
	pattern = { "help", "man" },
	command = "wincmd L",
})
-- }}}

-- {{{ set term options
local term_config = augroup("TermConfig", { clear = true })
autocmd("TermOpen", {
	group = term_config,
	pattern = "*",
	command = "setlocal nonumber norelativenumber",
})
-- }}}

-- {{{ Highlight yanked text
local highlight_yank = augroup("HighlightYank", { clear = true })
autocmd("TextYankPost", {
	group = highlight_yank,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 420 })
	end,
})
-- }}}

-- {{{ Disable indent-blankline for dashboard
function disable_for_dashboard()
	local buftype = vim.api.nvim_buf_get_option(0, "buftype")
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	if buftype == "nofile" and filetype == "dashboard" then
		vim.b.indent_blankline_enabled = false
	end
end
vim.cmd([[
    augroup IndentBlankline
        autocmd!
        autocmd FileType dashboard lua disable_for_dashboard()
    augroup END
]])
-- }}}

-- {{{ Code companion hook
local group = augroup("CodeCompanionHooks", {})

autocmd({ "User" }, {
	pattern = "CodeCompanionInline*",
	group = group,
	callback = function(request)
		if request.match == "CodeCompanionInlineFinished" then
			-- Format the buffer after the inline request has completed
			require("conform").format({ bufnr = request.buf })
		end
	end,
})
-- }}}
