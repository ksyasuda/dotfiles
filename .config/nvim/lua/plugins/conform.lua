return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			python = function(bufnr)
				if require("conform").get_formatter_info("ruff_format", bufnr).available then
					return {
						"ruff_fix",
						"ruff_organize_imports",
						"ruff_format",
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
			markdown = { "markdownlint" },
			["_"] = { "trim_whitespace" },
		},
		formatters = {
			shfmt = {
				append_args = { "-i", "0", "-ci", "-sr" },
			},
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "never",
		},
	},
}
