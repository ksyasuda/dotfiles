return {
	"sontungexpt/better-diagnostic-virtual-text",
	-- event = "LspAttach",
	enabled = true,
	config = function()
		local diagnostic = require("better-diagnostic-virtual-text")
		local vt = require("better-diagnostic-virtual-text.api")
		local tbl_insert = table.insert
		local strdisplaywidth = vim.fn.strdisplaywidth
		local space = function(n)
			return string.rep(" ", n)
		end

		local SEVERITY_SUFFIXS = {
			[vim.diagnostic.severity.ERROR] = "Error",
			[vim.diagnostic.severity.WARN] = "Warn",
			[vim.diagnostic.severity.INFO] = "Info",
			[vim.diagnostic.severity.HINT] = "Hint",
		}

		vt.format_line_chunks = function(
			ui_opts,
			line_idx,
			line_msg,
			severity,
			max_line_length,
			lasted_line,
			virt_text_offset,
			should_display_below,
			above_instead,
			removed_parts,
			diagnostic
		)
			local chunks = {}
			local first_line = line_idx == 1
			local severity_suffix = SEVERITY_SUFFIXS[severity]
			local msg = string.format("[%s]: %s", diagnostic.code, line_msg)

			local function hls(extend_hl_groups)
				local default_groups = {
					"DiagnosticVirtualText" .. severity_suffix,
					"BetterDiagnosticVirtualText" .. severity_suffix,
				}
				if extend_hl_groups then
					for i, hl in ipairs(extend_hl_groups) do
						default_groups[2 + i] = hl
					end
				end
				return default_groups
			end

			local message_highlight = hls()

			if should_display_below then
				local arrow_symbol = (above_instead and ui_opts.down_arrow or ui_opts.up_arrow):match("^%s*(.*)")
				local space_offset = space(virt_text_offset)
				if first_line then
					if not removed_parts.arrow then
						tbl_insert(chunks, {
							space_offset .. arrow_symbol,
							hls({
								"BetterDiagnosticVirtualTextArrow",
								"BetterDiagnosticVirtualTextArrow" .. severity_suffix,
							}),
						})
					end
				else
					tbl_insert(chunks, {
						space_offset .. space(strdisplaywidth(arrow_symbol)),
						message_highlight,
					})
				end
			else
				local arrow_symbol = ui_opts.arrow
				if first_line then
					if not removed_parts.arrow then
						tbl_insert(chunks, {
							arrow_symbol,
							hls({
								"BetterDiagnosticVirtualTextArrow",
								"BetterDiagnosticVirtualTextArrow" .. severity_suffix,
							}),
						})
					end
				else
					tbl_insert(chunks, {
						space(virt_text_offset + strdisplaywidth(arrow_symbol)),
						message_highlight,
					})
				end
			end

			if not removed_parts.left_kept_space then
				local tree_symbol = "   "
				if first_line then
					if not lasted_line then
						tree_symbol = above_instead and " └ " or " ┌ "
					end
				elseif lasted_line then
					tree_symbol = above_instead and " ┌ " or " └ "
				else
					tree_symbol = " │ "
				end
				tbl_insert(chunks, {
					tree_symbol,
					hls({ "BetterDiagnosticVirtualTextTree", "BetterDiagnosticVirtualTextTree" .. severity_suffix }),
				})
			end

			tbl_insert(chunks, {
				msg,
				message_highlight,
			})

			if not removed_parts.right_kept_space then
				local last_space = space(max_line_length - strdisplaywidth(msg) + ui_opts.right_kept_space)
				tbl_insert(chunks, { last_space, message_highlight })
			end

			return chunks
		end

		diagnostic.setup({
			ui = {
				wrap_line_after = 150, -- wrap the line after this length to avoid the virtual text is too long
				left_kept_space = 3, --- the number of spaces kept on the left side of the virtual text, make sure it enough to custom for each line
				right_kept_space = 3, --- the number of spaces kept on the right side of the virtual text, make sure it enough to custom for each line
				arrow = "  ",
				up_arrow = "  ",
				down_arrow = "  ",
				above = false, -- the virtual text will be displayed above the line
			},
			priority = 10000, -- the priority of virtual text
			inline = true,
		})
	end,
}
