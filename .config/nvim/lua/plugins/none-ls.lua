return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		local helpers = require("null-ls.helpers")
		-- syncronous formatting
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		local sources = {
			null_ls.builtins.completion.luasnip,
			-- null_ls.builtins.diagnostics.mypy,
			null_ls.builtins.diagnostics.pydoclint,
			null_ls.builtins.diagnostics.markdownlint,
			null_ls.builtins.formatting.black,
			null_ls.builtins.formatting.isort,
			null_ls.builtins.formatting.stylua,
			null_ls.builtins.formatting.markdownlint,
			null_ls.builtins.formatting.prettier, -- handled by lsp server
			null_ls.builtins.formatting.shfmt.with({
				filetypes = { "sh", "bash" },
				extra_args = { "-i", "0", "-ci", "-sr" },
			}),
			null_ls.builtins.formatting.gofmt,
			null_ls.builtins.formatting.goimports,
			null_ls.builtins.formatting.goimports_reviser,
			null_ls.builtins.hover.printenv,
		}

		require("null-ls").setup({
			border = "rounded",
			cmd = { "nvim" },
			debounce = 250,
			debug = false,
			default_timeout = 5000,
			diagnostic_config = {
				virtual_text = false,
				signs = true,
				underline = true,
				float = { border = "rounded", source = true },
				severity_sort = true,
			},
			-- diagnostics_format = "#{m}",
			diagnostics_format = "[#{c}] #{m} (#{s})",
			fallback_severity = vim.diagnostic.severity.ERROR,
			log_level = "warn",
			notify_format = "[null-ls] %s",
			on_init = nil,
			on_exit = nil,
			root_dir = require("null-ls.utils").root_pattern(".null-ls-root", "Makefile", ".git"),
			root_dir_async = nil,
			should_attach = nil,
			sources = sources,
			temp_dir = nil,
			update_in_insert = false,
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({
								async = false,
								bufnr = bufnr,
								filter = function(client)
									return client.name == "null-ls"
								end,
							})
						end,
					})
				end
			end,
		})
	end,
}
