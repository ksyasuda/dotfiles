local telescope = require("telescope")
local telescopeConfig = require("telescope.config")
local actions = require("telescope.actions")

local M = {}

function M.find_and_paste_image()
	local telescope = require("telescope.builtin")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	telescope.find_files({
		attach_mappings = function(_, map)
			local function embed_image(prompt_bufnr)
				local entry = action_state.get_selected_entry()
				local filepath = entry[1]
				actions.close(prompt_bufnr)

				local img_clip = require("img-clip")
				img_clip.paste_image(nil, filepath)
			end

			map("i", "<CR>", embed_image)
			map("n", "<CR>", embed_image)

			return true
		end,
	})
end

function M.setup()
	-- Clone the default Telescope configuration
	local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

	-- I want to search in hidden/dot files.
	table.insert(vimgrep_arguments, "--hidden")
	-- I don't want to search in the `.git` directory.
	table.insert(vimgrep_arguments, "--glob")
	table.insert(vimgrep_arguments, "!**/.git/*")
	vim.tbl_deep_extend("force", telescopeConfig.values, {
		mappings = {
			i = {
				["<C-h>"] = actions.results_scrolling_left,
				["<C-l>"] = actions.results_scrolling_right,
			},
		},
	})
end

return M
