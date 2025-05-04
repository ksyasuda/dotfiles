return {
	"ravitemer/mcphub.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	cmd = "MCPHub",
	build = "bundled_build.lua", -- Bundles mcp-hub locally
	config = function()
		vim.notify = require("notify")
		require("mcphub").setup({
			use_bundled_binary = true, -- Use local binary
			port = 37373, -- Port for MCP Hub Express API
			config = vim.fn.expand("~/.config/mcphub/servers.json"), -- Config file path
			native_servers = {}, -- add your native servers here
			auto_approve = true,
			extensions = {
				avante = {},
				codecompanion = {
					show_result_in_chat = true, -- Show tool results in chat
					make_vars = true, -- Create chat variables from resources
					make_slash_commands = true, -- make /slash_commands from MCP server prompts
				},
			},

			-- UI configuration
			ui = {
				window = {
					width = 0.8, -- Window width (0-1 ratio)
					height = 0.8, -- Window height (0-1 ratio)
					border = "rounded", -- Window border style
					relative = "editor", -- Window positioning
					zindex = 50, -- Window stack order
				},
			},

			-- Event callbacks
			on_ready = function(hub) end, -- Called when hub is ready
			on_error = function(err)
				vim.notify(err, "ERROR")
			end, -- Called on errors

			-- Logging configuration
			log = {
				level = vim.log.levels.WARN, -- Minimum log level
				to_file = false, -- Enable file logging
				file_path = nil, -- Custom log file path
				prefix = "MCPHub", -- Log message prefix
			},
		})
	end,
}
