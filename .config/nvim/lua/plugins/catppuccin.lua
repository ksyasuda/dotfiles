return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "macchiato", -- latte, frappe, macchiato, mocha
        term_colors = true,    -- sets terminal colors (e.g. `g:terminal_color_0`)
        integrations = {
            cmp = true,
            gitsigns = true,
            nvimtree = true,
            mini = {
                enabled = true,
                indentscope_color = "",
            },
            bufferline = true,
            dashboard = true,
            fidget = true,
            indent_blankline = {
                enabled = true,
                scope_color = "lavendar", -- catppuccin color (eg. `lavender`) Default: text
                colored_indent_levels = true,
            },
            copilot_vim = true,
            native_lsp = {
                enabled = true,
                virtual_text = {
                    errors = { "italic" },
                    hints = { "italic" },
                    warnings = { "italic" },
                    information = { "italic" },
                    ok = { "italic" },
                },
                underlines = {
                    errors = { "underline" },
                    hints = { "underline" },
                    warnings = { "underline" },
                    information = { "underline" },
                    ok = { "underline" },
                },
                inlay_hints = {
                    background = true,
                },
            },
            notify = true,
            treesitter = true,
            rainbow_delimiters = true,
            telescope = {
                enabled = true,
                -- style = "nvchad"
            },
            which_key = true
            -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        }
    }
}
