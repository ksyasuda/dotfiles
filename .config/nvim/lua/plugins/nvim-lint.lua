return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			markdown = { "markdownlint" },
			lua = { "luacheck" },
			python = { "ruff" },
			sh = { "shellcheck" },
			json = { "jsonlint" },
			yaml = { "yamllint" },
			vim = { "vint" },
			go = { "golangcilint" },
			typescript = { "eslint" },
			typescriptreact = { "eslint" },
		}
		lint.linters.jsonlint.cmd = "vscode-json-language-server"
		lint.linters.shellcheck.args = {
			"-s",
			"bash",
			"-o",
			"all",
			"-e",
			"2250",
		}
		-- Save original function
		local orig_try_lint = lint.try_lint

		lint.try_lint = function(...)
			local opts = select(2, ...)
			local bufnr = (type(opts) == "table" and opts.bufnr) or vim.api.nvim_get_current_buf()
			if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) ~= "" then
				return
			end
			return orig_try_lint(...)
		end
	end,
	event = { "BufReadPre", "BufNewFile" },
}
