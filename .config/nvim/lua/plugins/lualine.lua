local mcphub_spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local function mcphub_status()
	if not vim.g.loaded_mcphub then
		return "󰐻 -"
	end

	local status = vim.g.mcphub_status or "stopped"
	if status == "stopped" then
		return "󰐻 -"
	end

	if vim.g.mcphub_executing or status == "starting" or status == "restarting" then
		local frame = math.floor(vim.uv.now() / 100) % #mcphub_spinner_frames + 1
		return "󰐻 " .. mcphub_spinner_frames[frame]
	end

	return "󰐻 " .. (vim.g.mcphub_servers_count or 0)
end

local function mcphub_color()
	if not vim.g.loaded_mcphub then
		return { fg = "#6c7086" }
	end

	local status = vim.g.mcphub_status or "stopped"
	if status == "ready" or status == "restarted" then
		return { fg = "#50fa7b" }
	elseif status == "starting" or status == "restarting" then
		return { fg = "#ffb86c" }
	end

	return { fg = "#ff5555" }
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"AndreM222/copilot-lualine",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("lualine").setup({
			options = {
				-- theme = "catppuccin",
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = { "filename" },
				lualine_x = {
					"searchcount",
					{ mcphub_status, color = mcphub_color },
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
