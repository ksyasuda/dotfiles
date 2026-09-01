return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"AndreM222/copilot-lualine",
		"nvim-tree/nvim-web-devicons",
		"ravitemer/mcphub.nvim",
	},
	config = function()
		require("lualine").setup({
			options = {
				theme = "catppuccin",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = { "filename" },
				lualine_x = {
					"searchcount",
					require("mcphub.extensions.lualine"),
					{
						"copilot",
						symbols = {
							status = {
								icons = {
									disabled = " ",
									enabled = " ",
									sleep = " ",
									unknown = " ",
									warning = " ",
								},
								hl = {
									disabled = "#6272A4",
									enabled = "#50FA7B",
									sleep = "#AEB7D0",
									unknown = "#FF5555",
									warning = "#FFB86C",
								},
							},
							spinners = "dots",
							spinner_color = "#6272A4",
						},
						show_colors = true,
						show_loading = true,
					},
					"diagnostics",
					"encoding",
					{
						"fileformat",
						symbols = { dos = "", mac = "", unix = "" },
					},
					{ "filetype", colored = true },
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{
						"filename",
						file_status = true,
						path = 0,
						symbols = {
							modified = "[+]",
							readonly = "[-]",
							unnamed = "[No Name]",
						},
					},
				},
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			extensions = { "man", "quickfix", "toggleterm" },
		})
	end,
}
