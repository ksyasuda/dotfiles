local function set_python_path(path)
	local clients = vim.lsp.get_clients({
		bufnr = vim.api.nvim_get_current_buf(),
		name = "basedpyright",
	})
	for _, client in ipairs(clients) do
		if client.settings then
			client.settings.python = vim.tbl_deep_extend("force", client.settings.python or {}, { pythonPath = path })
		else
			client.config.settings =
				vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = path } })
		end
		client:notify("workspace/didChangeConfiguration", { settings = nil })
	end
end

return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.notify = require("notify")
		local servers = {
			"bashls",
			-- "jedi_language_server",
			"basedpyright",
			"jsonls",
			-- "yamlls",
			"vimls",
			"dotls",
			"dockerls",
			"html",
			"cssls",
			"lua_ls",
			"eslint",
			"ts_ls",
			"angularls",
			"ansiblels",
			"docker_compose_language_service",
			"golangci_lint_ls",
			"gopls",
		}
		-- Define the highlight color for float border
		vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89b4fa", bold = true })
		local border = {
			{ "╭", "FloatBorder" },
			{ "─", "FloatBorder" },
			{ "╮", "FloatBorder" },
			{ "│", "FloatBorder" },
			{ "╯", "FloatBorder" },
			{ "─", "FloatBorder" },
			{ "╰", "FloatBorder" },
			{ "│", "FloatBorder" },
		}

		for _, lsp in ipairs(servers) do
			if lsp == "lua_ls" then
				vim.lsp.config("lua_ls", {
					on_init = function(client)
						if client.workspace_folders then
							local path = client.workspace_folders[1].name
							if
								path ~= vim.fn.stdpath("config")
								and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
							then
								return
							end
						end

						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = {
								-- Tell the language server which version of Lua you're using
								-- (most likely LuaJIT in the case of Neovim)
								version = "LuaJIT",
							},
							-- Make the server aware of Neovim runtime files
							workspace = {
								checkThirdParty = false,
								library = {
									vim.env.VIMRUNTIME,
									-- Depending on the usage, you might want to add additional paths here.
									-- "${3rd}/luv/library",
									-- "${3rd}/busted/library",
								},
								-- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
								-- library = vim.api.nvim_get_runtime_file("", true)
							},
						})
					end,
					settings = {
						Lua = {},
					},
					handlers = {},
				})
				vim.lsp.enable(lsp)
			elseif lsp == "basedpyright" then
				vim.lsp.config(lsp, {
					analysis = {
						autoSearchPaths = true,
						diagnosticMode = "openFilesOnly",
						useLibraryCodeForTypes = true,
						autoFormatStrings = true,
					},
					diagnosticMode = "openFilesOnly",
					inlayHints = {
						callArgumentNames = true,
					},
					allowedUntypedLibraries = true,
					reportMissingTypeStubs = false,
					reportImportCycles = true,
					reportUnusedImport = true,
					on_attach = function(client, bufnr)
						vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
							client:exec_cmd({
								command = "basedpyright.organizeimports",
								arguments = { vim.uri_from_bufnr(bufnr) },
							})
						end, {
							desc = "Organize Imports",
						})

						vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
							desc = "Reconfigure basedpyright with the provided python path",
							nargs = 1,
							complete = "file",
						})
					end,
				})
				vim.lsp.enable(lsp)
			else
				vim.lsp.enable(lsp)
				-- vim.lsp.config(lsp, {
				-- handlers = {
				-- UNNSUUPPORTED
				-- ["textDocument/signatureHelp"] = vim.lsp.with(
				-- 	vim.lsp.handlers.signature_help,
				-- 	{ border = border }
				-- ),
				-- ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
				-- },
				-- })
			end
		end
	end,
}
