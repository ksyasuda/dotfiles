return {
	"neovim/nvim-lspconfig",
	dependencies = { "hrsh7th/cmp-nvim-lsp" },
	config = function()
		local servers = {
			"bashls",
			"basedpyright",
			"jsonls",
			"yamlls",
			"vimls",
			"dotls",
			"dockerls",
			"html",
			"cssls",
			"lua_ls",
			"vtsls",
			"ansiblels",
			"docker_compose_language_service",
			"docker_language_server",
			"gopls",
		}
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		vim.lsp.config("*", { capabilities = capabilities })

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
						version = "LuaJIT",
					},
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
							"/usr/lib/lua-language-server/meta/3rd/busted/library",
						},
					},
				})
			end,
			settings = { Lua = {} },
		})

		vim.lsp.config("basedpyright", {
			settings = {
				basedpyright = {
					analysis = {
						autoSearchPaths = true,
						diagnosticMode = "openFilesOnly",
						autoFormatStrings = true,
						inlayHints = {
							callArgumentNames = true,
						},
						diagnosticSeverityOverrides = {
							reportMissingTypeStubs = true,
							reportImportCycles = true,
							reportUnusedImport = true,
						},
					},
				},
			},
		})

		vim.lsp.enable(servers)
	end,
}
