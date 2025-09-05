--- @class CodeCompanion.InlineExtmark
--- @field unique_line_sign_text string Text used for sign when there's only a single line
--- @field first_line_sign_text string Text used for sign on the first line of multi-line section
--- @field last_line_sign_text string Text used for sign on the last line of multi-line section
--- @field extmark vim.api.keyset.set_extmark Extmark options passed to nvim_buf_set_extmark

local M = {}

--- @type CodeCompanion.InlineExtmark
local default_opts = {
	unique_line_sign_text = "",
	first_line_sign_text = "┌",
	last_line_sign_text = "└",
	extmark = {
		sign_hl_group = "DiagnosticWarn",
		sign_text = "│",
		priority = 1000,
	},
}

--- Helper function to set a line extmark with specified sign text
--- @param bufnr number
--- @param ns_id number
--- @param line_num number Line number
--- @param opts vim.api.keyset.set_extmark Extmark options
--- @param sign_type string Key in opts for the sign text to use
local function set_line_extmark(bufnr, ns_id, line_num, opts, sign_type)
	vim.api.nvim_buf_set_extmark(
		bufnr,
		ns_id,
		line_num - 1, -- Convert to 0-based index
		0,
		vim.tbl_deep_extend("force", opts.extmark or {}, {
			sign_text = opts[sign_type] or opts.extmark.sign_text,
		})
	)
end

--- Creates extmarks for inline code annotations
--- @param opts CodeCompanion.InlineExtmark Configuration options for the extmarks
--- @param data CodeCompanion.InlineArgs Data containing context information about the code block
--- @param ns_id number unique namespace id for the extmarks
local function create_extmarks(opts, data, ns_id)
	--- @type {bufnr: number, start_line: number, end_line: number}
	local context = data.context

	-- Handle the case where start and end lines are the same (unique line)
	if context.start_line == context.end_line then
		set_line_extmark(context.bufnr, ns_id, context.start_line, opts, "unique_line_sign_text")
		return
	end

	-- Set extmark for the first line with special options
	set_line_extmark(context.bufnr, ns_id, context.start_line, opts, "first_line_sign_text")

	-- Set extmarks for the middle lines with standard options
	for i = context.start_line + 1, context.end_line - 1 do
		vim.api.nvim_buf_set_extmark(context.bufnr, ns_id, i - 1, 0, opts.extmark)
	end

	-- Set extmark for the last line with special options
	if context.end_line > context.start_line then
		set_line_extmark(context.bufnr, ns_id, context.end_line, opts, "last_line_sign_text")
	end
end

--- Creates autocmds for CodeCompanionRequest events
--- @param opts CodeCompanion.InlineExtmark Configuration options passed from setup
local function create_autocmds(opts)
	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = { "CodeCompanionRequest*" },
		callback =
			--- @param args {buf: number, data : CodeCompanion.InlineArgs, match: string}
			function(args)
				local data = args.data or {}
				local context = data and data.context or {}
				if data and data.context then
					local ns_id = vim.api.nvim_create_namespace("CodeCompanionInline_" .. data.id)
					if args.match:find("StartedInline") then
						create_extmarks(opts, data, ns_id)
					elseif args.match:find("FinishedInline") then
						vim.api.nvim_buf_clear_namespace(context.bufnr, ns_id, 0, -1)
					end
				end
			end,
	})
end

--- @param opts? CodeCompanion.InlineExtmark Optional configuration to override defaults
function M.setup(opts)
	create_autocmds(vim.tbl_deep_extend("force", default_opts, opts or {}))
end

return M
