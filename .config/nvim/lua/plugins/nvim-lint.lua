return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			markdown = { "markdownlint" },
			lua = { "luacheck" },
			py = { "flake8", "pylint", "pydocstyle", "pycodestyle", "mypy" },
			sh = { "shellcheck" },
			json = { "jsonlint" },
			yaml = { "yamllint" },
			vim = { "vint" },
			go = { "golangcilint" },
		}
		local shellcheck = require("lint").linters.shellcheck
		shellcheck.args = {
			"-s",
			"bash",
			"-o",
			"all",
			"-e",
			"2250",
		}
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
	event = { "BufReadPre", "BufNewFile" },
}
