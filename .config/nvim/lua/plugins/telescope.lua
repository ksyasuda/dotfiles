return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nat-418/telescope-color-names.nvim",
		"ghassan0/telescope-glyph.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
		},
		"folke/noice.nvim",
	},
	cmd = "Telescope",
	keys = {
		{ "//", "<cmd>Telescope current_buffer_fuzzy_find previewer=false<cr>", desc = "Find in current buffer" },
		{
			"??",
			"<cmd>Telescope lsp_document_symbols theme=dropdown layout_config={width=0.5}<cr>",
			desc = "Document symbols",
		},
		{ "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
		{
			"<leader>fc",
			'<cmd>Telescope color_names theme=dropdown layout_config={width=0.45,height=25,prompt_position="bottom"} layout_strategy=vertical<cr>',
			desc = "Color names",
		},
		{
			"<leader>ff",
			"<cmd>Telescope find_files find_command=rg,--ignore,--follow,--hidden,--files prompt_prefix=🔍<cr>",
			desc = "Find files",
		},
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
		{
			"<leader>fG",
			'<cmd>Telescope glyph theme=dropdown layout_config={width=0.45,height=35,prompt_position="bottom"} layout_strategy=vertical<cr>',
			desc = "Glyphs",
		},
		{ "<leader>fr", "<cmd>Telescope oldfiles theme=dropdown layout_config={width=0.5}<cr>", desc = "Recent files" },
		{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
		{ "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "Git files" },
		{ "<leader>hc", "<cmd>Telescope commands<cr>", desc = "Commands" },
		{ "<leader>hk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
		{ "<leader>hm", "<cmd>Telescope man_pages theme=dropdown layout_config={width=0.75}<cr>", desc = "Man pages" },
		{ "<leader>hs", "<cmd>Telescope spell_suggest<cr>", desc = "Spelling suggestions" },
		{ "<leader>ht", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
		{ "<leader>hv", "<cmd>Telescope vim_options<cr>", desc = "Neovim options" },
		{ "<leader>s/", "<cmd>Telescope search_history<cr>", desc = "Search history" },
		{ "<leader>sF", "<cmd>Telescope fidget<cr>", desc = "Fidget history" },
		{
			"<leader>sf",
			"<cmd>Telescope find_files find_command=rg,--ignore,--follow,--hidden,--files prompt_prefix=🔍<cr>",
			desc = "Search files",
		},
		{ "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
		{ "<leader>sh", "<cmd>Telescope command_history<cr>", desc = "Command history" },
		{ "<leader>sm", "<cmd>Telescope man_pages<cr>", desc = "Man pages" },
		{ "<leader>Tc", "<cmd>Telescope colorscheme<cr>", desc = "Colorschemes" },
		{
			"<leader>TC",
			'<cmd>Telescope color_names theme=dropdown layout_config={width=0.45,height=25,prompt_position="bottom"} layout_strategy=vertical<cr>',
			desc = "Color names",
		},
		{
			"<leader>Tg",
			'<cmd>Telescope glyph theme=dropdown layout_config={width=0.45,height=35,prompt_position="bottom"} layout_strategy=vertical<cr>',
			desc = "Glyphs",
		},
		{ "<leader>TN", "<cmd>Telescope noice theme=dropdown layout_config={width=0.75}<cr>", desc = "Noice history" },
		{ "<leader>Tr", "<cmd>Telescope reloader<cr>", desc = "Reload Lua module" },
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
			-- ["ui-select"] = {
			-- 	require("telescope.themes").get_dropdown({
			-- 		winblend = 10,
			-- 		width = 0.5,
			-- 		prompt = " ",
			-- 		results_height = 15,
			-- 		previewer = true,
			-- 	}),
			-- },
		},
	},
	config = function(_, opts)
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local config = require("telescope.config")
		local vimgrep_arguments = vim.deepcopy(config.values.vimgrep_arguments)
		vim.list_extend(vimgrep_arguments, { "--hidden", "--glob", "!**/.git/*" })

		opts.defaults.vimgrep_arguments = vimgrep_arguments
		opts.defaults.mappings = vim.tbl_deep_extend("force", opts.defaults.mappings or {}, {
			i = {
				["<C-h>"] = actions.results_scrolling_left,
				["<C-l>"] = actions.results_scrolling_right,
			},
		})
		telescope.setup(opts)

		for _, extension in ipairs({ "color_names", "fzf", "glyph", "noice", "ui-select" }) do
			pcall(telescope.load_extension, extension)
		end
	end,
}
