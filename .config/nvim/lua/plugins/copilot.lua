return {
	"zbirenbaum/copilot.lua",
	opts = {
		panel = {
			enabled = true,
			auto_refresh = false,
			keymap = {
				jump_prev = "[[",
				jump_next = "]]",
				accept = "<CR>",
				refresh = "gr",
				open = "<M-CR>",
			},
			layout = {
				position = "bottom", -- | top | left | right | horizontal | vertical
				ratio = 0.4,
			},
		},
		suggestion = {
			enabled = false,
			auto_trigger = false,
			hide_during_completion = true,
			debounce = 75,
			keymap = {
				accept = "<M-l>",
				accept_word = false,
				accept_line = false,
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
		},
		-- filetypes = {
		--     yaml = false,
		--     markdown = false,
		--     help = false,
		--     gitcommit = false,
		--     gitrebase = false,
		--     hgcommit = false,
		--     svn = false,
		--     cvs = false,
		--     ["."] = false,
		-- },
		-- copilot_node_command = "node", -- Node.js version must be > 18.x
		server_opts_overrides = {
			trace = "verbose",
			settings = {
				advanced = {
					listCount = 10, -- #completions for panel
					inlineSuggestCount = 5, -- #completions for getCompletions
				},
			},
		},
	},
}
