return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- "jonarrien/telescope-cmdline.nvim",
		"nat-418/telescope-color-names.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		"ghassan0/telescope-glyph.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
		},
		"folke/noice.nvim",
	},
	opts = {
		defaults = {
			-- Default configuration for telescope goes here:
			-- config_key = value,
			layout_strategy = "flex",
			width = 0.9,
			wrap_results = true,
			preview = {
				border = true,
				borderchars = {
					"─",
					"│",
					"─",
					"│",
					"╭",
					"╮",
					"╯",
					"╰",
				},
				title = true,
				dynamic_preview_title = true,
				treesitter = true,
			},
			-- mappings = {
			-- 	i = {
			-- 		-- map actions.which_key to <C-h> (default: <C-/>)
			-- 		-- actions.which_key shows the mappings for your picker,
			-- 		-- e.g. git_{create, delete, ...}_branch for the git_branches picker
			-- 		["<C-/>"] = "which_key",
			-- 	},
			-- },
			file_ignore_patterns = { "^node_modules/", "^env/", "^__pycache__/" },
		},
		pickers = {
			-- Default configuration for builtin pickers goes here:
			-- picker_name = {
			--   picker_config_key = value,
			--   ...
			-- }
			-- Now the picker_config_key will be applied every time you call this
			-- builtin picker
			find_files = {
				-- theme = "dropdown"
			},
		},
		extensions = {
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
				-- the default case_mode is "smart_case"
			},
			glyph = {
				action = function(glyph)
					-- argument glyph is a table.
					-- {name="", value="", category="", description=""}
					-- vim.fn.setreg("*", glyph.value)
					-- print([[Press p or "*p to paste this glyph]] .. glyph.value)
					-- insert glyph when picked
					vim.api.nvim_put({ glyph.value }, "c", false, true)
				end,
			},
			cmdline = {
				-- Adjust telescope picker size and layout
				picker = {
					layout_config = {
						width = 120,
						height = 25,
					},
				},
				-- Adjust your mappings
				mappings = {
					complete = "<Tab>",
					run_selection = "<C-CR>",
					run_input = "<CR>",
				},
				-- Triggers any shell command using overseer.nvim (`:!`)
				overseer = {
					enabled = true,
				},
			},
			file_browser = {
				theme = "ivy",
				-- disables netrw and use telescope-file-browser in its place
				hijack_netrw = true,
				mappings = {
					["i"] = {
						-- your custom insert mode mappings
					},
					["n"] = {
						-- your custom normal mode mappings
					},
				},
			},
			["ui-select"] = {
				require("telescope.themes").get_dropdown({
					winblend = 10,
					width = 0.5,
					prompt = " ",
					results_height = 15,
					previewer = true,
				}),
			},
		},
	},
}
