return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
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
				telemetry = {
					telemetryLevel = "all",
				},
			},
		},
		copilot_node_command = "node", -- Node.js version must be > 20
		workspace_folders = {},
		-- copilot_model = "",
		disable_limit_reached_message = false, -- Set to `true` to suppress completion limit reached popup
		logger = {
			file = vim.fn.stdpath("log") .. "/copilot-lua.log",
			file_log_level = vim.log.levels.OFF,
			print_log_level = vim.log.levels.WARN,
			trace_lsp = "off", -- "off" | "messages" | "verbose"
			trace_lsp_progress = false,
			log_lsp_messages = false,
		},
		root_dir = function()
			return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
		end,
		server = {
			type = "nodejs", -- "nodejs" | "binary"
			custom_server_filepath = nil,
		},
	},
}
