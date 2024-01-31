-- Setup nvim-cmp.
local cmp = require 'cmp'
local lspkind = require('lspkind')
local lspconfig = require('lspconfig')
-- luasnip setup
local luasnip = require 'luasnip'
local highlight = require('cmp.utils.highlight')

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
        return false
    end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and
        vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match(
            "^%s*$") == nil
end

lspkind.init({ symbol_map = { Copilot = "" } })

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

cmp.setup({
    snippet = {
        expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end
    },
    capabilities = capabilities,
    mapping = {
        ['<C-p>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<C-n>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false
        },
        -- ["<Tab>"] = cmp.mapping(function(fallback)
        -- if cmp.visible() then
        --     cmp.select_next_item()
        -- elseif luasnip.expand_or_jumpable() then
        --     luasnip.expand_or_jump()
        -- else
        --     fallback()
        -- end
        -- end, { "i", "s" }),
        ["<Tab>"] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end),
        ['<S-Tab>'] = cmp.mapping(function()
            if cmp.visible() then cmp.select_prev_item() end
        end, { "i", "s" })
    },
    window = {
        completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
            col_offset = -3,
            side_padding = 0,
            border = "rounded",
            borderchars = {
                "─", "│", "─", "│", "╭", "╮", "╯", "╰"
            }
        },
        documentation = {
            border = "rounded",
            borderchars = {
                "─", "│", "─", "│", "╭", "╮", "╯", "╰"
            }
            -- padding = 15,
        }
    },
    formatting = {
        -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
        -- mode = 'symbol_text',
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            local kind = require("lspkind").cmp_format({
                mode = "symbol_text",
                maxwidth = 75,
                symbol_map = {
                    Copilot = "",
                    Function = "󰊕",
                    Text = "󰊄",
                    Method = "󰆧",
                    Operator = "󰆕",
                    Keyword = "󰌋",
                    Variable = "󰂡",
                    Field = "󰇽",
                    Class = "󰠱",
                    Interface = "",
                    Module = "",
                    Property = "󰜢",
                    Unit = "",
                    Value = "󰎠",
                    Enum = "",
                    Snippet = "",
                    Color = "󰏘",
                    File = "󰈙",
                    Reference = "",
                    Folder = "󰉋",
                    EnumMember = "",
                    Constant = "󰏿",
                    Struct = "",
                    Event = "",
                    TypeParameter = "󰅲"
                }
            })(entry, vim_item)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = " " .. strings[1] .. " "
            kind.menu = "    (" .. strings[2] .. ")"

            return kind
        end
        -- format = lspkind.cmp_format({
        --     mode = 'symbol_text', -- show only symbol annotations
        --     menu = ({
        --       buffer = "[Buffer]",
        --       nvim_lsp = "[LSP]",
        --       luasnip = "[LuaSnip]",
        --       nvim_lua = "[Lua]",
        --       latex_symbols = "[Latex]",
        --     })
        -- })
    },
    sources = cmp.config.sources({
        { name = "copilot",                  group_index = 2 }, { name = "path", group_index = 2 },
        { name = 'nvim_lsp',                 group_index = 2 },
        { name = 'nvim_lsp_signature_help',  group_index = 2 },
        { name = 'nvim_lsp_document_symbol', group_index = 2 },
        { name = 'vim-dadbod-completion',    group_index = 2 },
        { name = 'neorg',                    group_index = 2 }, -- For luasnip users.
        { name = 'luasnip',                  group_index = 2 }, -- For luasnip users.
        {
            name = 'buffer',
            option = {
                get_bufnrs = function()
                    local bufs = {}
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        bufs[vim.api.nvim_win_get_buf(win)] = true
                    end
                    return vim.tbl_keys(bufs)
                end
            }
        }
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, { { name = 'buffer' } }),
    sorting = {
        priority_weight = 2,
        comparators = {
            require("copilot_cmp.comparators").prioritize,
            require("copilot_cmp.comparators").score,
            require("copilot_cmp.comparators").recently_used,
            require("copilot_cmp.comparators").kind,
            require("copilot_cmp.comparators").sort_text,
            require("copilot_cmp.comparators").length,
            require("copilot_cmp.comparators").order,

            -- Below is the default comparitor list and order for nvim-cmp
            cmp.config.compare.offset,
            -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
            cmp.config.compare.exact, cmp.config.compare.score,
            cmp.config.compare.recently_used, cmp.config.compare.locality,
            cmp.config.compare.kind, cmp.config.compare.sort_text,
            cmp.config.compare.length, cmp.config.compare.order
        }
    }
})

cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = 'path' } }, {
        { name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } }
    })
})

local servers = {
    'bashls', 'pyright', 'jsonls', 'yamlls', 'vimls', 'dotls', 'dockerls',
    'html', 'cssls', 'lua_ls', 'eslint', 'tsserver', 'angularls', 'ansiblels'
}

for _, lsp in ipairs(servers) do
    if lsp == 'lua_ls' then
        lspconfig[lsp].setup {
            -- on_attach = my_custom_on_attach,
            -- on_attach = highlight_symbol_under_cursor(),
            capabilities = capabilities,
            callSnippet = "Replace",
            settings = {
                Lua = {
                    runtime = {
                        version = 'Lua 5.4',
                        path = {
                            '?.lua', '?/init.lua',
                            -- vim.fn.expand '~/.luarocks/share/lua/5.4/?.lua',
                            -- vim.fn.expand '~/.luarocks/share/lua/5.4/?/init.lua',
                            '/usr/share/5.3/?.lua',
                            '/usr/share/lua/5.3/?/init.lua',
                            '/usr/share/5.4/?.lua',
                            '/usr/share/lua/5.4/?/init.lua'
                        }
                    },
                    workspace = {
                        library = {
                            -- vim.fn.expand '~/.luarocks/share/lua/5.3',
                            '/usr/share/lua/5.1', '/usr/share/lua/5.3',
                            '/usr/share/lua/5.4'
                        }
                    }
                }
            }
        }
    else
        lspconfig[lsp].setup { capabilities = capabilities }
    end
end

cmp.event:on("menu_opened",
    function() vim.b.copilot_suggestion_hidden = true end)
cmp.event:on("menu_closed",
    function() vim.b.copilot_suggestion_hidden = false end)
