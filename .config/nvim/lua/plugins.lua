local lsp_dev = {}

vim.cmd [[packadd packer.nvim]]
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'nvim-lua/plenary.nvim'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            require('nvim-treesitter.install').update({ with_sync = true })
        end
    }

    -- TELESCOPE {{{

    use { 'nvim-telescope/telescope.nvim' }
    use { 'nvim-telescope/telescope-file-browser.nvim' }
    use 'nvim-telescope/telescope-dap.nvim'
    use { 'ghassan0/telescope-glyph.nvim' }
    use { 'nat-418/telescope-color-names.nvim' }
    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run =
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    }

    -- }}}

    -- LSP/DEV {{{

    -- COPILOT {{{
    use {
        "zbirenbaum/copilot.lua",
        event = "VimEnter",
        config = function()
            require('copilot').setup({
                panel = {
                    enabled = false,
                    auto_refresh = false,
                    keymap = {
                        jump_prev = "[[",
                        jump_next = "]]",
                        accept = "<CR>",
                        refresh = "gr",
                        open = "<C-CR>"
                    },
                    layout = {
                        position = "right", -- | top | left | right
                        ratio = 0.4
                    }
                },
                suggestion = {
                    enabled = false,
                    auto_trigger = false,
                    debounce = 75,
                    keymap = {
                        accept = "<C-l>",
                        -- accept = "<Right>",
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = "<C-]>"
                    }
                },
                -- filetypes = {
                --   yaml = false,
                --   markdown = false,
                --   help = false,
                --   gitcommit = false,
                --   gitrebase = false,
                --   hgcommit = false,
                --   svn = false,
                --   cvs = false,
                --   ["."] = false,
                -- },
                copilot_node_command = 'node', -- Node version must be < 18
                plugin_manager_path = vim.fn.stdpath("data") ..
                    "/site/pack/packer",
                server_opts_overrides = {
                    trace = "verbose",
                    settings = {
                        advanced = {
                            listCount = 10,        -- #completions for panel
                            inlineSuggestCount = 4 -- #completions for getCompletions
                        }
                    }
                }
            })
        end
    }

    use { "zbirenbaum/copilot-cmp" }
    -- }}}
    -- CHATGPT {{{

    use({
        "jackMort/ChatGPT.nvim",
        commit = "24bcca7",
        config = function()
            require("chatgpt").setup({
                api_key_cmd = "cat /home/stickuser/.config/openai/apikey",
                yank_register = "+",
                edit_with_instructions = {
                    diff = false,
                    keymaps = {
                        close = "<C-c>",
                        accept = "<C-y>",
                        toggle_diff = "<C-d>",
                        toggle_settings = "<C-o>",
                        cycle_windows = "<Tab>",
                        use_output_as_input = "<C-i>"
                    }
                },
                chat = {
                    welcome_message = "HELLO FREUD",
                    loading_text = "Loading, please wait ...",
                    question_sign = "",
                    answer_sign = "ﮧ",
                    max_line_length = 120,
                    sessions_window = {
                        border = {
                            style = "rounded",
                            text = { top = " Sessions " }
                        },
                        win_options = {
                            winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
                        }
                    },
                    keymaps = {
                        close = { "<C-c>" },
                        yank_last = "<C-y>",
                        yank_last_code = "<C-k>",
                        scroll_up = "<C-u>",
                        scroll_down = "<C-d>",
                        new_session = "<C-n>",
                        cycle_windows = "<Tab>",
                        cycle_modes = "<C-f>",
                        select_session = "<Space>",
                        rename_session = "r",
                        delete_session = "d",
                        draft_message = "<C-d>",
                        toggle_settings = "<C-o>",
                        toggle_message_role = "<C-r>",
                        toggle_system_role_open = "<C-s>",
                        stop_generating = "<C-x>"
                    }
                },
                popup_layout = {
                    default = "center",
                    center = { width = "80%", height = "80%" },
                    right = { width = "30%", width_settings_open = "50%" }
                },
                popup_window = {
                    border = {
                        highlight = "FloatBorder",
                        style = "rounded",
                        text = { top = " ChatGPT " }
                    },
                    win_options = {
                        wrap = true,
                        linebreak = true,
                        foldcolumn = "1",
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
                    },
                    buf_options = { filetype = "markdown" }
                },
                system_window = {
                    border = {
                        highlight = "FloatBorder",
                        style = "rounded",
                        text = { top = " SYSTEM " }
                    },
                    win_options = {
                        wrap = true,
                        linebreak = true,
                        foldcolumn = "2",
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
                    }
                },
                popup_input = {
                    prompt = "  ",
                    border = {
                        highlight = "FloatBorder",
                        style = "rounded",
                        text = { top_align = "center", top = " Prompt " }
                    },
                    win_options = {
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
                    },
                    submit = "<C-Enter>",
                    submit_n = "<Enter>",
                    max_visible_lines = 20
                },
                settings_window = {
                    border = { style = "rounded", text = { top = " Settings " } },
                    win_options = {
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
                    }
                },
                openai_params = {
                    model = "gpt-3.5-turbo",
                    frequency_penalty = 0,
                    presence_penalty = 0,
                    max_tokens = 300,
                    temperature = 0,
                    top_p = 1,
                    n = 1
                },
                openai_edit_params = {
                    model = "code-davinci-edit-001",
                    temperature = 0,
                    top_p = 1,
                    n = 1
                },
                actions_paths = {},
                show_quickfixes_cmd = "Trouble quickfix",
                predefined_chat_gpt_prompts =
                "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv"
            })
        end,
        requires = {
            "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        }
    })

    -- }}}
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end
    })
    use {
        "L3MON4D3/LuaSnip",
        -- tag = "v2.*",
        run = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" }
    }
    use { 'folke/neodev.nvim' }
    use { 'saadparwaiz1/cmp_luasnip' }
    use { 'hrsh7th/cmp-buffer' }
    use { 'hrsh7th/cmp-cmdline' }
    use { 'hrsh7th/cmp-nvim-lsp' }
    use { 'hrsh7th/cmp-nvim-lsp-document-symbol' }
    use { 'hrsh7th/cmp-nvim-lsp-signature-help' }
    use { 'hrsh7th/cmp-nvim-lua' }
    use { 'hrsh7th/cmp-path' }
    use { 'hrsh7th/nvim-cmp' }
    use { 'https://git.sr.ht/~whynothugo/lsp_lines.nvim' }
    use { 'jose-elias-alvarez/null-ls.nvim' }
    use { 'neovim/nvim-lspconfig' }
    use { 'onsails/lspkind-nvim' }

    -- DAP {{{

    use 'mfussenegger/nvim-dap'
    use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
    use { 'mfussenegger/nvim-dap-python' }
    use { 'theHamsta/nvim-dap-virtual-text' }

    -- }}}

    -- DADBOD {{{

    use { 'tpope/vim-dadbod' }
    use { 'kristijanhusak/vim-dadbod-ui' }
    use { 'kristijanhusak/vim-dadbod-completion' }

    -- }}}

    -- }}}

    -- UI {{{

    use {
        'glepnir/dashboard-nvim',
        -- event = 'VimEnter',
        requires = { 'nvim-tree/nvim-web-devicons' }
    }
    use {
        'j-hui/fidget.nvim',
        tag = 'legacy',
        config = function()
            require("fidget").setup {
                -- options
            }
        end
    }
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use { 'kyazdani42/nvim-web-devicons' }
    use { 'norcalli/nvim-colorizer.lua' }
    use { 'akinsho/nvim-bufferline.lua' }
    use { 'andweeb/presence.nvim' }
    use { 'folke/which-key.nvim' }
    use { 'kyazdani42/nvim-tree.lua' }
    use { 'lewis6991/gitsigns.nvim' }
    use { 'rcarriga/nvim-notify' }
    use { 'stevearc/dressing.nvim' }
    use { 'HiPhish/rainbow-delimiters.nvim' }

    -- }}}

    -- EXTRAS {{{

    use {
        "nvim-neorg/neorg",
        -- tag = "*",
        ft = "norg",
        after = "nvim-treesitter", -- You may want to specify Telescope here as well
        config = function()
            require('neorg').setup {
                load = {
                    ["core.defaults"] = {},                                 -- Loads default behaviour
                    ["core.concealer"] = {},                                -- Adds pretty icons to your documents
                    ["core.completion"] = { config = { engine = "nvim-cmp" } }, -- Adds completion
                    ["core.dirman"] = {                                     -- Manages Neorg workspaces
                        config = { workspaces = { notes = "~/notes" } }
                    }
                }
            }
        end
    }
    use 'jiangmiao/auto-pairs'
    use 'pechorin/any-jump.vim'
    use 'tpope/vim-commentary'
    use 'tpope/vim-dotenv'
    use 'tpope/vim-surround'
    use 'voldikss/vim-floaterm'
    use 'wakatime/vim-wakatime'
    use 'rmagatti/goto-preview'

    -- }}}

    -- COLORSCHEMES {{{

    use { 'Mofiqul/dracula.nvim' }
    use({
        'NTBBloodbath/doom-one.nvim',
        setup = function()
            -- Add color to cursor
            vim.g.doom_one_cursor_coloring = false
            -- Set :terminal colors
            vim.g.doom_one_terminal_colors = true
            -- Enable italic comments
            vim.g.doom_one_italic_comments = false
            -- Enable TS support
            vim.g.doom_one_enable_treesitter = true
            -- Color whole diagnostic text or only underline
            vim.g.doom_one_diagnostics_text_color = false
            -- Enable transparent background
            vim.g.doom_one_transparent_background = false

            -- Pumblend transparency
            vim.g.doom_one_pumblend_enable = false
            vim.g.doom_one_pumblend_transparency = 20

            -- Plugins integration
            vim.g.doom_one_plugin_neorg = true
            vim.g.doom_one_plugin_barbar = false
            vim.g.doom_one_plugin_telescope = true
            vim.g.doom_one_plugin_neogit = true
            vim.g.doom_one_plugin_nvim_tree = true
            vim.g.doom_one_plugin_dashboard = true
            vim.g.doom_one_plugin_startify = true
            vim.g.doom_one_plugin_whichkey = true
            vim.g.doom_one_plugin_indent_blankline = true
            vim.g.doom_one_plugin_vim_illuminate = false
            vim.g.doom_one_plugin_lspsaga = false
        end,
        config = function()
            vim.cmd("colorscheme doom-one")
            vim.cmd(
                "highlight Pmenu ctermfg=white ctermbg=black gui=NONE guifg=white guibg=#282C34")
            vim.cmd("highlight PmenuSel guifg=purple guibg=red")
        end
    })
    use { 'olimorris/onedarkpro.nvim' }
    use { 'projekt0n/github-nvim-theme' }

    use { "catppuccin/nvim", as = "catppuccin" }

    -- }}}
end)
