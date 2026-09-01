return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{
			"<leader>fb",
			function()
				Snacks.explorer()
			end,
			desc = "File browser",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>nc",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss notifications",
		},
		{
			"<leader>nh",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification history",
		},
		{
			"<leader>nt",
			function()
				Snacks.explorer()
			end,
			desc = "File explorer",
		},
		{
			"<leader>sn",
			function()
				Snacks.win({
					file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
					width = 0.6,
					height = 0.6,
					wo = {
						spell = false,
						wrap = false,
						signcolumn = "yes",
						statuscolumn = " ",
						conceallevel = 3,
					},
				})
			end,
			desc = "Neovim news",
		},
		{
			"<leader>Tn",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notifications",
		},
	},
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true },
		indent = {
			indent = {
				priority = 1,
				enabled = true, -- enable indent guides
				char = "│",
				only_scope = true, -- only show indent guides of the scope
				only_current = false, -- only show indent guides in the current window
				-- hl = "SnacksIndent", ---@type string|string[] hl groups for indent guides
				-- can be a list of hl groups to cycle through
				hl = {
					"SnacksIndent1",
					"SnacksIndent2",
					"SnacksIndent3",
					"SnacksIndent4",
					"SnacksIndent5",
					"SnacksIndent6",
					"SnacksIndent7",
					"SnacksIndent8",
				},
			},
			animate = {
				-- enabled = vim.fn.has("nvim-0.10") == 1,
				enabled = false,
				style = "out",
				easing = "linear",
				duration = {
					step = 20, -- ms per step
					total = 500, -- maximum duration
				},
			},
			filter = function(buf)
				return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
			end,
		},
		input = {
			enabled = true,
			icon = " ",
			icon_hl = "SnacksInputIcon",
			icon_pos = "left",
			prompt_pos = "title",
			win = { style = "input" },
		},
		lazygit = { enabled = true },
		picker = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 3000, -- default timeout in ms
			width = { min = 40, max = 0.4 },
			height = { min = 1, max = 0.6 },
			-- editor margin to keep free. tabline and statusline are taken into account automatically
			margin = { top = 0, right = 1, bottom = 0 },
			padding = true, -- add 1 cell of left/right padding to the notification window
			sort = { "level", "added" }, -- sort by level and time
			-- minimum log level to display. TRACE is the lowest
			-- all notifications are stored in history
			level = vim.log.levels.TRACE,
			icons = {
				error = "  ",
				warn = "  ",
				info = "  ",
				debug = "  ",
				trace = "  ",
			},
			keep = function()
				return vim.fn.getcmdpos() > 0
			end,
			---@type snacks.notifier.style
			style = "compact",
			top_down = true, -- place notifications from top to bottom
			date_format = "%R", -- time format for notifications
			-- format for footer when more lines are available
			-- `%d` is replaced with the number of lines.
			-- only works for styles with a border
			---@type string|boolean
			more_format = " ↓ %d lines ",
			refresh = 50, -- refresh at most every 50ms
		},
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = false },
		statuscolumn = { enabled = false },
		words = { enabled = false },
		terminal = { enabled = false },
		win = { enabled = true },
		styles = {
			input = {
				backdrop = false,
				position = "float",
				border = "rounded",
				title_pos = "center",
				height = 1,
				width = 60,
				relative = "editor",
				noautocmd = true,
				row = 2,
				-- relative = "cursor",
				-- row = -3,
				-- col = 0,
				wo = {
					winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
					cursorline = false,
				},
				bo = {
					filetype = "snacks_input",
					buftype = "prompt",
				},
				--- buffer local variables
				b = {
					completion = false, -- disable blink completions in input
				},
				keys = {
					n_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "n", expr = true },
					i_esc = { "<esc>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
					i_cr = { "<cr>", { "cmp_accept", "confirm" }, mode = { "i", "n" }, expr = true },
					i_tab = { "<tab>", { "cmp_select_next", "cmp" }, mode = "i", expr = true },
					i_ctrl_w = { "<c-w>", "<c-s-w>", mode = "i", expr = true },
					i_up = { "<up>", { "hist_up" }, mode = { "i", "n" } },
					i_down = { "<down>", { "hist_down" }, mode = { "i", "n" } },
					q = "cancel",
				},
			},
		},
	},
}
