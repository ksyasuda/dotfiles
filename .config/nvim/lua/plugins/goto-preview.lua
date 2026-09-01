return {
	"rmagatti/goto-preview",
	keys = {
		{
			"gpc",
			function()
				require("goto-preview").close_all_win()
			end,
			desc = "Close preview windows",
		},
		{
			"gpd",
			function()
				require("goto-preview").goto_preview_definition()
			end,
			desc = "Preview definition",
		},
		{
			"gpi",
			function()
				require("goto-preview").goto_preview_implementation()
			end,
			desc = "Preview implementation",
		},
	},
}
