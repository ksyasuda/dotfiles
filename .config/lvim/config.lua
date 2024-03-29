-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "onedarker"
lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
-- Nvimtree
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.show_icons.git = 1
lvim.builtin.nvimtree.hide_dotfiles = 0
-- Treesitter
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.treesitter.matchup.enable = true
lvim.builtin.treesitter.context_commentstring.enable = true
local components = require("lvim.core.lualine.components")
lvim.builtin.lualine.sections.lualine_a = { "mode" }
lvim.builtin.lualine.sections.lualine_c = { components.python_env }
lvim.builtin.lualine.sections.lualine_y = { components.location, }
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "css",
  "rust",
  "java",
  "yaml",
  "dockerfile",
  "markdown",
  "make"
}
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- formatters
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { exe = "black", filetypes = { "python" } },
  { exe = "isort", filetypes = { "python" } },
  {
    exe = "prettier",
    args = { "--print-with", "80" },
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  },
  { exe = "shfmt", filetypes = { "shell", "sh" }, args = {'-i=0','-sr', '-ci'} },
}

-- linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { exe = "flake8", filetypes = { "python" } },
  {
    exe = "shellcheck",
    filetypes = { "shell", "sh" },
  },
}

-- lsp signature cfg
local lsp_signature_cfg = {
  debug = false, -- set to true to enable debug logging
  -- log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
  -- default is  ~/.cache/nvim/lsp_signature.log
  verbose = false, -- show debug line number

  bind = true, -- This is mandatory, otherwise border config won't get registered.
               -- If you want to hook lspsaga or other signature handler, pls set to false
  doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
                 -- set to 0 if you DO NOT want any API comments be shown
                 -- This setting only take effect in insert mode, it does not affect signature help in normal
                 -- mode, 10 by default

  floating_window = true, -- show hint in a floating window, set to false for virtual text only mode

  floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
  -- will set to true when fully tested, set to false will use whichever side has more space
  -- this setting will be helpful if you do not want the PUM and floating win overlap
  fix_pos = true,  -- set to true, the floating window will not auto-close until finish all parameters
  hint_enable = true, -- virtual hint enable
  hint_prefix = "🐼 ",  -- Panda for parameter
  hint_scheme = "String",
  use_lspsaga = false,  -- set to true if you want to use lspsaga popup
  hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
  max_height = 20, -- max height of signature floating_window, if content is more than max_height, you can scroll down
                   -- to view the hiding contents
  max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
  handler_opts = {
    border = "rounded"   -- double, rounded, single, shadow, none
  },

  always_trigger = true, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

  auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
  extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
  zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

  padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc

  transparency = 85, -- disabled by default, allow floating win transparent value 1~100
  shadow_blend = 36, -- if you using shadow as border use this set the opacity
  shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
  timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
  toggle_key = '<C-l>' -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
}

-- Additional Plugins
lvim.plugins = {
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function()
      require "lsp_signature".setup(lsp_signature_cfg)
    end
  },
  {
    "rmagatti/goto-preview",
    config = function()
    require('goto-preview').setup {
          width = 100; -- Width of the floating window
          height = 25; -- Height of the floating window
          default_mappings = false; -- Bind default mappings
          debug = false; -- Print debug information
          opacity = nil; -- 0-100 opacity level of the floating window where 100 is fully transparent.
          post_open_hook = nil -- A function taking two arguments, a buffer and a window to be ran as a hook.
          -- You can use "default_mappings = true" setup option
          -- Or explicitly set keybindings
          -- vim.cmd("nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>")
          -- vim.cmd("nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>")
          -- vim.cmd("nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>")
      }
    end
  },
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 1
    end,
  },
  {
		"ethanholz/nvim-lastplace",
		event = "BufRead",
		config = function()
			require("nvim-lastplace").setup({
				lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
				lastplace_ignore_filetype = {
					"gitcommit", "gitrebase", "svn", "hgcommit",
				},
				lastplace_open_folds = true,
			})
		end,
	},
  'wakatime/vim-wakatime',
  'ap/vim-css-color',
  "p00f/nvim-ts-rainbow",
  "tzachar/cmp-tabnine",
  "onsails/lspkind-nvim",
  "rcarriga/nvim-notify",
}

-- add jedi_language_server
lvim.lsp.templates_dir = join_paths(get_runtime_dir(), "after", "ftplugin")
local opts = {}
require("lvim.lsp.manager").setup("jedi_language_server", opts)

require'lspconfig'.sqlls.setup{}

-- add bashls
-- require('lspconfig').bashls.setup{}
require'lspconfig'.bashls.setup{}

-- Setup nvim-cmp.
local cmp = require'cmp'
-- cmp.setup({
--   snippet = {
--     -- REQUIRED - you must specify a snippet engine
--     expand = function(args)
--       -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
--       require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
--       -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
--       -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
--     end,
--   },
--   mapping = {
--     ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
--     ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
--     ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
--     ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
--     ['<C-e>'] = cmp.mapping({
--       i = cmp.mapping.abort(),
--       c = cmp.mapping.close(),
--     }),
--     ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
--   },
--   sources = cmp.config.sources({
--     { name = 'nvim_lsp' },
--   }, {
--     { name = 'buffer' },
--   })
-- })

-- -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline('/', {
--   sources = {
--     { name = 'buffer' }
--   }
-- })

-- -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(':', {
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   })
-- })

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
require('lspconfig')['jedi_language_server'].setup {
  capabilities = capabilities
}
require('lspconfig')['sqls'].setup {
  capabilities = capabilities
}
require('lspconfig')['bashls'].setup {
  capabilities = capabilities
}
require('lspconfig')['dockerls'].setup {
  capabilities = capabilities
}
require('lspconfig')['jsonls'].setup {
  capabilities = capabilities
}
require('lspconfig')['sumneko_lua'].setup {
  capabilities = capabilities
}
require('lspconfig')['pyright'].setup {
  capabilities = capabilities
}
require('lspconfig')['dotls'].setup {
  capabilities = capabilities
}
require('lspconfig')['yamlls'].setup {
  capabilities = capabilities
}
require('lspconfig')['html'].setup {
  capabilities = capabilities
}
require('lspconfig')['eslint'].setup {
  capabilities = capabilities
}

-- lsp_signature
-- require'lsp_signature'.setup(lsp_signature_cfg)

require('goto-preview').setup {
    width = 150; -- Width of the floating window
    height = 45; -- Height of the floating window
    border = {"↖", "─" ,"┐", "│", "┘", "─", "└", "│"}; -- Border characters of the floating window
    default_mappings = true; -- Bind default mappings
    debug = false; -- Print debug information
    opacity = 55; -- 0-100 opacity level of the floating window where 100 is fully transparent.
    resizing_mappings = false; -- Binds arrow keys to resizing the floating window.
    post_open_hook = nil; -- A function taking two arguments, a buffer and a window to be ran as a hook.
    -- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
    focus_on_open = true; -- Focus the floating window when opening it.
    dismiss_on_move = false; -- Dismiss the floating window when moving the cursor.
    force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
    bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
}

-- init.lua
vim.g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = true,
    position = 'right',
    relative_width = true,
    width = 30,
    show_numbers = false,
    show_relative_numbers = false,
    show_symbol_details = true,
    preview_bg_highlight = 'Pmenu',
    keymaps = { -- These keymaps can be a string or a table for multiple keys
        close = {"<Esc>", "q"},
        goto_location = "<Cr>",
        focus_location = "o",
        hover_symbol = "<C-space>",
        toggle_preview = "K",
        rename_symbol = "r",
        code_actions = "a",
    },
    lsp_blacklist = {},
    symbol_blacklist = {},
    symbols = {
        File = {icon = "", hl = "TSURI"},
        Module = {icon = "", hl = "TSNamespace"},
        Namespace = {icon = "", hl = "TSNamespace"},
        Package = {icon = "", hl = "TSNamespace"},
        Class = {icon = "𝓒", hl = "TSType"},
        Method = {icon = "ƒ", hl = "TSMethod"},
        Property = {icon = "", hl = "TSMethod"},
        Field = {icon = "", hl = "TSField"},
        Constructor = {icon = "", hl = "TSConstructor"},
        Enum = {icon = "ℰ", hl = "TSType"},
        Interface = {icon = "ﰮ", hl = "TSType"},
        Function = {icon = "", hl = "TSFunction"},
        Variable = {icon = "", hl = "TSConstant"},
        Constant = {icon = "", hl = "TSConstant"},
        String = {icon = "𝓐", hl = "TSString"},
        Number = {icon = "#", hl = "TSNumber"},
        Boolean = {icon = "⊨", hl = "TSBoolean"},
        Array = {icon = "", hl = "TSConstant"},
        Object = {icon = "⦿", hl = "TSType"},
        Key = {icon = "🔐", hl = "TSType"},
        Null = {icon = "NULL", hl = "TSType"},
        EnumMember = {icon = "", hl = "TSField"},
        Struct = {icon = "𝓢", hl = "TSType"},
        Event = {icon = "🗲", hl = "TSType"},
        Operator = {icon = "+", hl = "TSOperator"},
        TypeParameter = {icon = "𝙏", hl = "TSParameter"}
    }
}

-- lsp-kind
local lspkind = require('lspkind')
cmp.setup {
  formatting = {
    format = lspkind.cmp_format({
      with_text = false, -- do not show text alongside icons
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      -- before = function (entry, vim_item)
      --   ...
      -- return vim_item
      -- end
    })
  }
}

-- tabnine
require'cmp'.setup {
 sources = {
 	{ name = 'cmp_tabnine' },
 },
}

local source_mapping = {
	buffer = "[Buffer]",
	nvim_lsp = "[LSP]",
	nvim_lua = "[Lua]",
	cmp_tabnine = "[TN]",
	path = "[Path]",
}

-- tabnine
require'cmp'.setup {
	sources = {
		{ name = 'cmp_tabnine' },
	},
	formatting = {
		format = function(entry, vim_item)
			vim_item.kind = lspkind.presets.default[vim_item.kind]
			local menu = source_mapping[entry.source.name]
			if entry.source.name == 'cmp_tabnine' then
				if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
					menu = entry.completion_item.data.detail .. ' ' .. menu
				end
				vim_item.kind = ''
			end
			vim_item.menu = menu
			return vim_item
		end
	},
}

-- nvim-notify
-- require("notify").setup({
--   -- Animation style (see below for details)
--   stages = "fade_in_slide_out",

--   -- Function called when a new window is opened, use for changing win settings/config
--   on_open = nil,

--   -- Function called when a window is closed
--   on_close = nil,

--   -- Render function for notifications. See notify-render()
--   render = "default",

--   -- Default timeout for notifications
--   timeout = 4000,

--   -- For stages that change opacity this is treated as the highlight behind the window
--   -- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
--   background_colour = "Normal",

--   -- Minimum width for notification windows
--   minimum_width = 50,

--   -- Icons for the different levels
--   icons = {
--     ERROR = "",
--     WARN = "",
--     INFO = "",
--     DEBUG = "",
--     TRACE = "✎",
--   },
-- })

-- custom settings
local init_custom_options = function()
  local custom_options = {
    relativenumber = true,
    colorcolumn = "80",
    scrolloff = 10,
    ignorecase = true,
    smartcase = true,
    tabstop = 4,
    shiftwidth = 4,
    undofile = false,
  }

  for k, v in pairs(custom_options) do
    vim.opt[k] = v
  end
end
init_custom_options()

-- move windows to right side of screen
vim.cmd("autocmd! BufEnter * if &ft ==# 'help' | wincmd L | endif")
vim.cmd("autocmd! BufEnter * if &ft ==# 'man' | wincmd L | endif")
-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
--   { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
-- }
