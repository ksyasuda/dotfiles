return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"j-hui/fidget.nvim",
		"ravitemer/mcphub.nvim",
	},
	opts = {
		adapters = {
			-- {{{ HTTP
			http = {
				-- {{{ COPILOT
				copilot = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							name = "copilot",
							opts = {
								stream = true,
								tools = true,
								vision = true,
							},
							features = {
								text = true,
								tokens = true,
							},
							model = {
								-- default = "claude-3.7-sonnet-thought",
								-- default = "o3-mini",
								-- default = "gemini-2.0-flash-001",
								default = "gpt-4.1",
								-- default = "gpt-4o",
								-- default = "o3-mini-2025-01-31",
								-- choices = {
								-- 	["o3-mini-2025-01-31"] = { opts = { can_reason = true } },
								-- 	["o1-2024-12-17"] = { opts = { can_reason = true } },
								-- 	["o1-mini-2024-09-12"] = { opts = { can_reason = true } },
								-- 	"gpt-4o-2024-08-06",
								-- 	"claude-3.7-sonnet-thought",
								-- 	"claude-3.7-sonnet",
								-- "claude-3.5-sonnet",
								-- 	"gemini-2.0-flash-001",
								-- },
							},
							-- max_tokens = {
							-- 	default = 65536,
							-- },
						},
					})
				end,
				-- }}}
				-- {{{ LLAMA_CPP
				llama_cpp = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						name = "llama.cpp",
						formatted_name = "llama.cpp",
						opts = {
							stream = false,
						},
						schema = {
							-- model = {
							-- 	default = "qwen2.5-coder-14b-instruct",
							-- 	choices = {
							-- 		["qwen2.5-coder-14b-instruct"] = { opts = { can_reason = true } },
							-- 		["/models/lmstudio-community/DeepSeek-R1-Distill-Qwen-7B-GGUF/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf"] = {
							-- 			opts = { can_reason = true },
							-- 		},
							-- 		["/models/lmstudio-community/Qwen2.5-7B-Instruct-1M-GGUF/Qwen2.5-7B-Instruct-1M-Q4_K_M.gguf"] = {
							-- 			opts = { can_reason = true },
							-- 		},
							-- 	},
							-- },
							temperature = {
								order = 2,
								mapping = "parameters",
								type = "number",
								optional = true,
								default = 0.2,
								validate = function(n)
									return n >= 0 and n <= 2, "Must be between 0 and 2"
								end,
							},
						},
						env = {
							url = "http://localhost:8080",
							chat_url = "/v1/chat/completions",
						},
					})
				end,
				-- }}}
				-- {{{ OPENROUTER
				openrouter = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						env = {
							url = "https://openrouter.ai/api",
							api_key = "cmd:cat $HOME/.openrouterapikey",
							chat_url = "/v1/chat/completions",
						},
						schema = {
							model = {
								default = "google/gemini-2.5-pro-exp-03-25:free",
								-- default = "deepseek/deepseek-chat-v3-0324:free",
								-- default = "google/gemini-2.0-flash-thinking-exp:free",
								-- default = "deepseek/deepseek-r1-distill-qwen-32b:free",
								-- default = "qwen/qwen-2.5-coder-32b-instruct:free",
							},
						},
					})
				end,
				-- }}}
			},
			-- }}}
			-- {{{ ACP
			acp = {
				gemini_cli = function()
					return require("codecompanion.adapters").extend("gemini_cli", {
						defaults = {
							auth_method = "oauth-personal", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
							mcpServers = {},
							timeout = 20000, -- 20 seconds
						},
					})
				end,
			},
			-- }}}
		},
		strategies = {
			chat = {
				adapter = "copilot",
				-- adapter = "openrouter",
				roles = {
					llm = function(adapter)
						if adapter.model == nil then
							return " Assistant"
						else
							return " Assistant ("
								.. adapter.formatted_name
								.. " - "
								.. adapter.parameters.model
								.. ")"
						end
					end,
					user = " User",
				},
				slash_commands = {
					["file"] = {
						opts = {
							provider = "telescope",
						},
					},
					["symbols"] = {
						opts = {
							provider = "telescope",
						},
					},
					["buffer"] = {
						opts = {
							provider = "telescope",
						},
					},
					["terminal"] = {
						opts = {
							provider = "telescope",
						},
					},
				},
				opts = {
					---Decorate the user message before it's sent to the LLM
					---@param message string
					---@param adapter CodeCompanion.Adapter
					---@param context table
					---@return string
					prompt_decorator = function(message, adapter, context)
						return string.format([[<prompt>%s</prompt>]], message)
					end,
					completion_provider = "cmp",
				},
			},
			inline = {
				adapter = "copilot",
				-- adapter = "openrouter",
			},
		},
		display = {
			action_palette = {
				provider = "telescope",
				width = 75,
				heigth = 45,
			},
			chat = {
				layout = "vertical",
				border = "single",
				intro_message = "Welcome to CodeCompanion ✨! Press ? for options",
				show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
				separator = "─", -- The separator between the different messages in the chat buffer
				show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
				show_settings = false, -- Show LLM settings at the top of the chat buffer?
				show_token_count = true, -- Show the token count for each response?
				start_in_insert_mode = false, -- Open the chat buffer in insert mode?
			},
			window = {
				layout = "vertical",
				position = nil,
				border = "rounded",
				height = 0.45,
				width = 0.45,
				relative = "editor",
				opts = {
					breakindent = true,
					cursorcolumn = false,
					cursorline = false,
					foldcolumn = "0",
					linebreak = true,
					list = false,
					numberwidth = 1,
					signcolumn = "no",
					spell = false,
					wrap = true,
				},
			},
			diff = {
				enabled = true,
				provider = "mini_diff",
			},
			---Customize how tokens are displayed
			---@param tokens number
			---@param adapter CodeCompanion.Adapter
			---@return string
			token_count = function(tokens, adapter)
				return " (" .. tokens .. " tokens)"
			end,
		},
		opts = {
			log_level = "DEBUG",
			-- log_level = "TRACE",
		},
		extensions = {
			mcphub = {
				callback = "mcphub.extensions.codecompanion",
				opts = {
					show_result_in_chat = true, -- Show the mcp tool result in the chat buffer
					make_vars = true, -- make chat #variables from MCP server resources
					make_slash_commands = true, -- make /slash_commands from MCP server prompts
				},
			},
		},
	},
	init = function()
		require("utils.codecompanion.fidget-spinner"):init()
		require("utils.codecompanion.extmarks").setup()
	end,
}
