return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	opts = {
		flavour = "macchiato", -- latte, frappe, macchiato, mocha
		transparent_background = false, -- disables setting the background color.
		float = {
			transparent = false, -- enable transparent floating windows
			solid = false, -- use solid styling for floating windows, see |winborder|
		},
		show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
		term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
		dim_inactive = {
			enabled = false, -- dims the background color of inactive window
			shade = "dark",
			percentage = 0.15, -- percentage of the shade to apply to the inactive window
		},
		no_italic = false, -- Force no italic
		no_bold = false, -- Force no bold
		no_underline = false, -- Force no underline
		styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
			comments = { "italic" }, -- Change the style of comments
			conditionals = { "italic" },
			loops = { "bold" },
			functions = { "bold", "italic" },
			keywords = { "bold" },
			strings = {},
			variables = { "bold" },
			numbers = { "bold" },
			booleans = { "bold" },
			properties = { "bold" },
			types = { "bold" },
			operators = { "bold" },
			-- miscs = {}, -- Uncomment to turn off hard-coded styles
		},
		color_overrides = {},
		custom_highlights = {},
		default_integrations = true,
		auto_integrations = false,
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
			diffview = true,
			fidget = true,
			noice = true,
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
			render_markdown = true,
			telescope = {
				enabled = true,
				-- style = "nvchad"
			},
			which_key = true,
			-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
		},
	},
}
