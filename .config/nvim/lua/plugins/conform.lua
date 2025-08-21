return {
	"stevearc/conform.nvim",
	opts = {
		on_init = function(client)
			require("conform").formatters.shfmt = {
				append_args = { "-i", "0", "-ci", "-sr" },
			}
		end,
		formatters_by_ft = {
			python = function(bufnr)
				if require("conform").get_formatter_info("ruff_format", bufnr).available then
					return {
						"ruff_fix",
						"ruff_format",
						"ruff_organize_imports",
					}
				else
					return { "isort", "black" }
				end
			end,
			sh = { "shfmt" },
			lua = { "stylua" },
			go = { "goimports", "gofmt" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			md = { "markdownlint" },
			["*"] = { "codespell" },
			["_"] = { "trim_whitespace" },
		},
		format_on_save = {
			-- These options will be passed to conform.format()
			timeout_ms = 500,
			-- lsp_format = "fallback",
		},
	},
}
