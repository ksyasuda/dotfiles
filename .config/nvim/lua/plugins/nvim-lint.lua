return {
	"mfussenegger/nvim-lint",
	event = { "BufNewFile", "BufReadPre" },
	config = function()
		local lint = require("lint")
		local parser = require("lint.parser")

		lint.linters.pydoclint = {
			cmd = "pydoclint",
			args = { "--show-filenames-in-every-violation-message=true", "-q" },
			stdin = false,
			stream = "stderr",
			ignore_exitcode = true,
			parser = parser.from_pattern("(.+):(%d+): (DOC%d+): (.+)", { "file", "lnum", "code", "message" }, nil, {
				severity = vim.diagnostic.severity.WARN,
				source = "pydoclint",
			}),
		}
		local python_linters = { "ruff" }
		if vim.fn.executable("pydoclint") == 1 then
			table.insert(python_linters, "pydoclint")
		end

		lint.linters_by_ft = {
			go = { "golangcilint" },
			json = { "jsonlint" },
			lua = { "luacheck" },
			markdown = { "markdownlint" },
			python = python_linters,
			sh = { "shellcheck" },
			typescript = { "eslint" },
			typescriptreact = { "eslint" },
			vim = { "vint" },
			yaml = { "yamllint" },
		}

		lint.linters.shellcheck.args = { "-s", "bash", "-o", "all", "-e", "2250" }

		local lint_group = vim.api.nvim_create_augroup("LintOnSave", { clear = true })
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = lint_group,
			callback = function(args)
				if vim.bo[args.buf].buftype ~= "" then
					return
				end
				lint.try_lint(nil, { bufnr = args.buf })
				if vim.fn.executable("codespell") == 1 then
					lint.try_lint("codespell", { bufnr = args.buf })
				end
			end,
		})
	end,
}
