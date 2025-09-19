return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.notify = require("notify")
		local servers = {
			"bashls",
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
			"ruff",
		}
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		for _, lsp in ipairs(servers) do
			if lsp == "lua_ls" then
				vim.lsp.config("lua_ls", {
					capabilities = capabilities,
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
									"/usr/lib/lua-language-server/meta/3rd/busted/library",
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
					root_dir = function(bufnr, on_dir)
						if not vim.fn.bufname(bufnr):match("%.txt$") then
							on_dir(vim.fn.getcwd())
						end
					end,
				})
			elseif lsp == "basedpyright" then
				vim.lsp.config(lsp, {
					capabilities = capabilities,
					settings = {
						basedpyright = {
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
							reportMissingTypeStubs = true,
							reportImportCycles = true,
							reportUnusedImport = true,
						},
						python = {
							analysis = {
								ignore = { "*" },
							},
						},
					},
				})
			elseif lsp == "ruff" then
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
					callback = function(args)
						local client = vim.lsp.get_client_by_id(args.data.client_id)
						if client == nil then
							return
						end
						if client.name == "ruff" then
							-- Disable hover in favor of Pyright
							client.server_capabilities.hoverProvider = false
						end
					end,
					desc = "LSP: Disable hover capability from Ruff",
				})
				vim.lsp.config(lsp, {
					settings = {
						configuration = vim.fn.stdpath("config") .. "/lua/utils/ruff.toml",
						logLevel = "info",
					},
				})
			end
			vim.lsp.enable(lsp)
		end
	end,
}
