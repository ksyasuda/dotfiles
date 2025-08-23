return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-nvim-lsp-signature-help",
		"hrsh7th/cmp-nvim-lsp-document-symbol",
		"hrsh7th/cmp-nvim-lsp",
		-- "hrsh7th/cmp-path",
		"rafamadriz/friendly-snippets",
		"Jezda1337/nvim-html-css",
		"https://codeberg.org/FelipeLema/cmp-async-path",
	},
	config = function()
		-- Setup nvim-cmp.
		local cmp = require("cmp")
		local lspkind = require("lspkind")
		-- luasnip setup
		local luasnip = require("luasnip")

		local cmp_autopairs = require("nvim-autopairs.completion.cmp")

		local has_words_before = function()
			if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
				return false
			end
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
		end
		require("luasnip.loaders.from_vscode").lazy_load()

		lspkind.init({ symbol_map = { Copilot = "" } })

		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "nvim_lsp_document_symbol" },
			}, {
				{ name = "buffer" },
			}),
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({ { name = "path" } }, {
				{ name = "cmdline", option = { ignore_cmds = { "Man", "!" } } },
			}),
			matching = { disallow_symbol_nonprefix_matching = false },
		})

		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

		require("cmp").setup({
			snippet = {
				expand = function(args)
					-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
					luasnip.lsp_expand(args.body) -- For `luasnip` users.
					-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
					-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
				end,
			},
			mapping = {
				["<C-p>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-n>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				}),
				["<Tab>"] = vim.schedule_wrap(function(fallback)
					if cmp.visible() and has_words_before() then
						cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
					elseif luasnip.locally_jumpable(1) then
						luasnip.jump(1)
					else
						fallback()
					end
				end),
				-- ["<Tab>"] = cmp.mapping(function(fallback)
				-- 	if cmp.visible() and has_words_before() then
				-- 		cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				-- 	elseif luasnip.locally_jumpable(1) then
				-- 		luasnip.jump(1)
				-- 	else
				-- 		fallback()
				-- 	end
				-- end, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			},
			window = {
				completion = {
					col_offset = -3,
					side_padding = 0,
					border = "rounded",
					-- winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
					winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder,Search:None",
					borderchars = {
						"─",
						"│",
						"─",
						"│",
						"╭",
						"╮",
						"╯",
						"╰",
					},
				},
				documentation = {
					border = "rounded",
					-- winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
					winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder,Search:None",
					borderchars = {
						"─",
						"│",
						"─",
						"│",
						"╭",
						"╮",
						"╯",
						"╰",
					},
					-- padding = 15,
				},
			},
			formatting = {
				-- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
				mode = "symbol_text",
				fields = { "kind", "abbr", "menu" },
				expandable_indicator = true,
				format = function(entry, vim_item)
					local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
					local strings = vim.split(kind.kind, "%s", { trimempty = true })
					kind.kind = " " .. (strings[1] or "") .. " "
					kind.menu = "    (" .. (strings[2] or "") .. ")"

					return kind
				end,
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp_signature_help", group_index = 0 },
				{ name = "lazydev", group_index = 0 },
				{ name = "nvim_lsp", group_index = 1 },
				{ name = "copilot", group_index = 1 },
				{ name = "codecompanion", group_index = 2 },
				{ name = "async_path", group_index = 2 },
				{ name = "nvim_lsp_document_symbol", group_index = 2 },
				{ name = "luasnip", group_index = 2 }, -- For luasnip users.
				{ name = "render-markdown", group_index = 2 },
				{
					name = "html-css",
					group_indx = 2,
					option = {
						enable_on = { "html", "jsx", "tsx", "typescript", "typescriptreact" }, -- html is enabled by default
						notify = false,
						documentation = {
							auto_show = true, -- show documentation on select
						},
						-- add any external scss like one below
						style_sheets = {
							"https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
							"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css",
						},
					},
				},
				{
					name = "buffer",
					option = {
						get_bufnrs = function()
							local bufs = {}
							for _, win in ipairs(vim.api.nvim_list_wins()) do
								bufs[vim.api.nvim_win_get_buf(win)] = true
							end
							return vim.tbl_keys(bufs)
						end,
					},
				},
				-- { name = 'ultisnips' }, -- For ultisnips users.
				-- { name = 'snippy' }, -- For snippy users.
			}, { { name = "buffer" } }),
			sorting = {
				priority_weight = 2,
				comparators = {
					require("copilot_cmp.comparators").prioritize,
					cmp.config.compare.offset,
					cmp.config.compare.exact,
					require("copilot_cmp.comparators").score,
					require("copilot_cmp.comparators").recently_used,
					cmp.config.compare.locality,
					require("copilot_cmp.comparators").kind,
					require("copilot_cmp.comparators").sort_text,
					require("copilot_cmp.comparators").length,
					require("copilot_cmp.comparators").order,
				},
			},
		})
	end,
}
