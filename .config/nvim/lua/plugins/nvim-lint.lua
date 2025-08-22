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
		}
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
			local bufnr = vim.api.nvim_get_current_buf()
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })

			-- Skip linting for non-file buffers (like hover docs)
			if buftype ~= "" then
				return
			end

			return orig_try_lint(...)
		end

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			callback = function()
				lint.try_lint()
			end,
		})
	end,
	event = { "BufReadPre", "BufNewFile" },
}
