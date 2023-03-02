vim.cmd [[packadd packer.nvim]]
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'nvim-lua/plenary.nvim'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    }

    use {
      'nvim-lualine/lualine.nvim',
      requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }


    use {
      "zbirenbaum/copilot.lua",
      event = "VimEnter",
      config = function ()
          vim.defer_fn(function()
            require('copilot').setup({
              panel = {
                enabled = true,
                auto_refresh = false,
                keymap = {
                  jump_prev = "[[",
                  jump_next = "]]",
                  accept = "<CR>",
                  refresh = "gr",
                  open = "<C-CR>"
                },
              },
              suggestion = {
                enabled = true,
                auto_trigger = true,
                debounce = 75,
                keymap = {
                 accept = "<Tab>",
                 next = "<M-]>",
                 prev = "<M-[>",
                 dismiss = "<C-]>",
                },
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
              plugin_manager_path = vim.fn.stdpath("data") .. "/site/pack/packer",
              server_opts_overrides = {},
            })
        require("copilot.suggestion").toggle_auto_trigger()
        end, 100)
      end,
    }

    use {
      "zbirenbaum/copilot-cmp",
      after = { "copilot.lua" },
      config = function ()
          require("copilot_cmp").setup({
              method = "getCompletionsCycling",
              -- formatters = {
              --   insert_text = require("copilot_cmp.format").remove_existing
              -- }
          })
      end
    }

    use {
        'junegunn/fzf',
        run = function() vim.fn['fzf#install']() end
    }

    -- use {
    --     "lewis6991/hover.nvim",
    --     config = function()
    --         require("hover").setup {
    --             init = function()
    --                 -- Require providers
    --                 require("hover.providers.lsp")
    --                 -- require('hover.providers.gh')
    --                 -- require('hover.providers.jira')
    --                 require('hover.providers.man')
    --                 require('hover.providers.dictionary')
    --             end,
    --             preview_opts = {
    --                 border = "rounded"
    --                 -- border = {
    --                 --     { "╭", "FloatBorder" },
    --                 --     { "─", "FloatBorder" },
    --                 --     { "╮", "FloatBorder" },
    --                 --     { "│", "FloatBorder" },
    --                 --     { "╯", "FloatBorder" },
    --                 --     { "─", "FloatBorder" },
    --                 --     { "╰", "FloatBorder" },
    --                 --     { "│", "FloatBorder" },
    --                 -- }
    --             },
    --             -- Whether the contents of a currently open hover window should be moved
    --             -- to a :h preview-window when pressing the hover keymap.
    --             preview_window = false,
    --             title = true
    --         }

    --         -- Setup keymaps
    --         vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
    --         vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
    --     end
    -- }

    use 'ap/vim-css-color'
    use 'jiangmiao/auto-pairs'
    use 'junegunn/fzf.vim'
    use 'pechorin/any-jump.vim'
    use 'tpope/vim-commentary'
    use 'tpope/vim-surround'
    use 'voldikss/vim-floaterm'
    use 'wakatime/vim-wakatime'

    use {
        'akinsho/nvim-bufferline.lua'
    }
    use {
        'andweeb/presence.nvim'
    }
    use {
        'folke/which-key.nvim'
    }
    use {
        'glepnir/dashboard-nvim'
    }
    use {
        'kyazdani42/nvim-tree.lua'
    }
    use 'kyazdani42/nvim-web-devicons'
    use {
        'lewis6991/gitsigns.nvim'
    }
    use {
        'nvim-telescope/telescope.nvim'
    }
    use {
        'nvim-telescope/telescope-file-browser.nvim'
    }

    use {
        'ojroques/nvim-lspfuzzy'
    }

    use 'L3MON4D3/LuaSnip'
    -- use 'amrbashir/nvim-docs-view'
    use {
        'hrsh7th/nvim-cmp'
    }
    use {
        'hrsh7th/cmp-nvim-lsp'
    }
    use {
        'hrsh7th/cmp-nvim-lua'
    }
    use {
        'hrsh7th/cmp-nvim-lsp-signature-help'
    }
    use {
        'hrsh7th/cmp-path'
    }
    use {
        'hrsh7th/cmp-buffer'
    }
    use {
        'j-hui/fidget.nvim'
    }
    use {
        'jose-elias-alvarez/null-ls.nvim'
    }
    use {
        'ksyasuda/lsp_lines.nvim'
    }
    use {
        'neovim/nvim-lspconfig'
    }
    use {
        'onsails/lspkind-nvim'
    }
    -- use 'ray-x/lsp_signature.nvim'
    use {
        'rmagatti/goto-preview'
    }
    use 'saadparwaiz1/cmp_luasnip'
    use 'williamboman/nvim-lsp-installer'

    use {
        'Mofiqul/dracula.nvim'
    }
    use {
        'NTBBloodbath/doom-one.nvim',
        setup = function()
        -- Add color to cursor
            vim.g.doom_one_cursor_coloring = false
            -- Set :terminal colors
            vim.g.doom_one_terminal_colors = false
            -- Enable italic comments
            vim.g.doom_one_italic_comments = true
            -- Enable TS support
            vim.g.doom_one_enable_treesitter = true
            -- Color whole diagnostic text or only underline
            vim.g.doom_one_diagnostics_text_color = true
            -- Enable transparent background
            vim.g.doom_one_transparent_background = false

            -- Pumblend transparency
            vim.g.doom_one_pumblend_enable = false
            vim.g.doom_one_pumblend_transparency = 20

            -- Plugins integration
            vim.g.doom_one_plugin_neorg = false
            vim.g.doom_one_plugin_barbar = false
            vim.g.doom_one_plugin_telescope = true
            vim.g.doom_one_plugin_neogit = true
            vim.g.doom_one_plugin_nvim_tree = true
            vim.g.doom_one_plugin_dashboard = true
            vim.g.doom_one_plugin_startify = false
            vim.g.doom_one_plugin_whichkey = true
            vim.g.doom_one_plugin_indent_blankline = true
            vim.g.doom_one_plugin_vim_illuminate = false
            vim.g.doom_one_plugin_lspsaga = true
        end,
    }
    use {
        'olimorris/onedarkpro.nvim'
    }
    use {
        'projekt0n/github-nvim-theme'
    }

    use({
      "jackMort/ChatGPT.nvim",
        config = function()
          require("chatgpt").setup({
              welcome_message = WELCOME_MESSAGE, -- set to "" if you don't like the fancy robot
              loading_text = "loading",
              question_sign = "", -- you can use emoji if you want e.g. 🙂
              answer_sign = "ﮧ", -- 🤖
              max_line_length = 120,
              yank_register = "+",
              chat_layout = {
                relative = "editor",
                position = "50%",
                size = {
                  height = "80%",
                  width = "80%",
                },
              },
              chat_window = {
                filetype = "chatgpt",
                border = {
                  highlight = "FloatBorder",
                  style = "rounded",
                  text = {
                    top = " ChatGPT ",
                  },
                },
              },
              chat_input = {
                prompt = "  ",
                border = {
                  highlight = "FloatBorder",
                  style = "rounded",
                  text = {
                    top_align = "center",
                    top = " Prompt ",
                  },
                },
                win_options = {
                  winhighlight = "Normal:Normal",
                },
              },
              openai_params = {
                model = "text-davinci-003",
                frequency_penalty = 0,
                presence_penalty = 0,
                max_tokens = 300,
                temperature = 0,
                top_p = 1,
                n = 1,
              },
              keymaps = {
                close = "<C-c>",
                yank_last = "<C-y>",
                scroll_up = "<C-u>",
                scroll_down = "<C-d>",
              }
            }
            )end,
        requires = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
          "nvim-telescope/telescope.nvim"
        }
    })
end)
