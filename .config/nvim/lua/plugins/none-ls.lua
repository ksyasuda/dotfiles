return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		local helpers = require("null-ls.helpers")
		-- syncronous formatting
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		-- null_ls.setup({
		-- on_attach = function(client)
		--     if client.supports_method "textDocument/formatting" then
		--         vim.cmd([[
		--         augroup LspFormatting
		--             autocmd! * <buffer>
		--             autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
		--         augroup END
		--         ]])
		--     end
		-- end,
		-- })
		-- you can reuse a shared lspconfig on_attach callback here

		require("null-ls").setup({
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
							-- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
							-- vim.lsp.buf.formatting_sync()
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
			sources = {
				null_ls.builtins.completion.luasnip,
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.isort,
				null_ls.builtins.diagnostics.mypy,
				null_ls.builtins.diagnostics.markdownlint,
				null_ls.builtins.diagnostics.pylint,
				-- null_ls.builtins.diagnostics.pydocstyle.with({
				-- 	extra_arags = { "--config=$ROOT/setup.cfg" },
				-- }),
				-- null_ls.builtins.diagnostics.pydoclint,
				null_ls.builtins.formatting.stylua,
				-- null_ls.builtins.formatting.stylua.with({
				-- 	extra_args = { '--config-path', vim.fn.expand('~/.config/stylua.toml') },
				-- }),
				null_ls.builtins.formatting.markdownlint,
				null_ls.builtins.formatting.prettier, -- handled by lsp server
				null_ls.builtins.formatting.shfmt.with({
					filetypes = { "sh", "bash" },
					extra_args = { "-i", "0", "-ci", "-sr" },
				}),
				null_ls.builtins.formatting.gofmt,
				null_ls.builtins.formatting.goimports,
				null_ls.builtins.formatting.goimports_reviser,
				-- null_ls.builtins.diagnostics.actionlint,
			},
		})
	end,
}
