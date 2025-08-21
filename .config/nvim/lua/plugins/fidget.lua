return {
	"j-hui/fidget.nvim",
	opts = {
		-- text = {
		-- 	spinner = "pipe", -- animation shown when tasks are ongoing
		-- 	done = "✔", -- character shown when all tasks are complete
		-- 	commenced = "Started", -- message shown when task starts
		-- 	completed = "Completed", -- message shown when task completes
		-- },
		-- align = {
		-- 	bottom = true, -- align fidgets along bottom edge of buffer
		-- 	right = true, -- align fidgets along right edge of buffer
		-- },
		progress = {
			poll_rate = 0, -- How and when to poll for progress messages
			suppress_on_insert = false, -- Suppress new messages while in insert mode
			ignore_done_already = false, -- Ignore new tasks that are already complete
			ignore_empty_message = false, -- Ignore new tasks that don't contain a message
			-- Clear notification group when LSP server detaches
			clear_on_detach = function(client_id)
				local client = vim.lsp.get_client_by_id(client_id)
				return client and client.name or nil
			end,
			-- How to get a progress message's notification group key
			notification_group = function(msg)
				return msg.lsp_client.name
			end,
			ignore = {}, -- List of LSP servers to ignore

			-- Options related to how LSP progress messages are displayed as notifications
			display = {
				render_limit = 16, -- How many LSP messages to show at once
				done_ttl = 3, -- How long a message should persist after completion
				done_icon = "✔", -- Icon shown when all LSP progress tasks are complete
				done_style = "Constant", -- Highlight group for completed LSP tasks
				progress_ttl = math.huge, -- How long a message should persist when in progress
				-- Icon shown when LSP progress tasks are in progress
				progress_icon = { "dots" },
				-- Highlight group for in-progress LSP tasks
				progress_style = "WarningMsg",
				group_style = "Title", -- Highlight group for group name (LSP server name)
				icon_style = "Question", -- Highlight group for group icons
				priority = 30, -- Ordering priority for LSP notification group
				skip_history = true, -- Whether progress notifications should be omitted from history
				-- How to format a progress message
				format_message = require("fidget.progress.display").default_format_message,
				-- How to format a progress annotation
				format_annote = function(msg)
					return msg.title
				end,
				-- How to format a progress notification group's name
				format_group_name = function(group)
					return tostring(group)
				end,
				overrides = { -- Override options from the default notification config
					rust_analyzer = { name = "rust-analyzer" },
				},
			},

			-- Options related to Neovim's built-in LSP client
			lsp = {
				progress_ringbuf_size = 0, -- Configure the nvim's LSP progress ring buffer size
				log_handler = false, -- Log `$/progress` handler invocations (for debugging)
			},
		},
		notification = {
			window = {
				winblend = 0,
			},
			poll_rate = 10, -- How frequently to update and render notifications
			filter = vim.log.levels.INFO, -- Minimum notifications level
			history_size = 128, -- Number of removed messages to retain in history
			override_vim_notify = false, -- Automatically override vim.notify() with Fidget
			-- How to configure notification groups when instantiated
			configs = { default = require("fidget.notification").default_config },
			-- Conditionally redirect notifications to another backend
			redirect = function(msg, level, opts)
				if opts and opts.on_open then
					return require("fidget.integration.nvim-notify").delegate(msg, level, opts)
				end
			end,

			-- Options related to how notifications are rendered as text
			view = {
				stack_upwards = true, -- Display notification items from bottom to top
				icon_separator = " ", -- Separator between group name and icon
				group_separator = "---", -- Separator between notification groups
			},
		},
		integration = {
			["nvim-tree"] = {
				enable = true, -- Integrate with nvim-tree/nvim-tree.lua (if installed)
			},
			["xcodebuild-nvim"] = {
				enable = false, -- Integrate with wojciech-kulik/xcodebuild.nvim (if installed)
			},
		},
		-- Options related to logging
		logger = {
			level = vim.log.levels.WARN, -- Minimum logging level
			max_size = 10000, -- Maximum log file size, in KB
			float_precision = 0.01, -- Limit the number of decimals displayed for floats
			-- Where Fidget writes its logs to
			path = string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache")),
		},
	},
}
