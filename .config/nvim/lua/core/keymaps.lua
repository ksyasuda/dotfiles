local map = vim.keymap.set
local term = require("utils.terminal")
local map_from_table = require("utils.keymaps.converters.from_table").set_keybindings
local add_to_whichkey = require("utils.keymaps.converters.whichkey").addToWhichKey
local term_factory = term.term_factory
local term_toggle = term.term_toggle

local opts = { silent = true, noremap = true }
local nosilent = { silent = false, noremap = true }

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Create a custom command with the given trigger, command, and description
--- @param trigger string The command trigger
--- @param command string The command to execute
--- @param description string Description of the command
--- @return nil
function create_custom_command(trigger, command, description)
	vim.api.nvim_create_user_command(trigger, command, { desc = description })
end
-- Custom commands
create_custom_command("Config", "edit ~/.config/nvim", "Edit nvim configuration")
create_custom_command("Keymaps", "edit ~/.config/nvim/lua/core/keymaps.lua", "Edit Hyprland keybindings")
create_custom_command("Hypr", "edit ~/.config/hypr/hyprland.conf", "Edit Hyprland configuration")

vim.keymap.set("", "<Leader>tl", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics virtual text" })

-- {{{ Basic Mappings
local basic_mappings = {
	{ key = "<C-u>", cmd = "<C-u>zz", desc = "Scroll up and center", mode = "n" },
	{ key = "n", cmd = "nzzzv", desc = "Next search result and center", mode = "n" },
	{ key = "N", cmd = "Nzzzv", desc = "Previous search result and center", mode = "n" },
	{ key = "<leader>p", cmd = '"_dP', desc = "Paste without yanking", mode = "x", group = "Paste in place" },
	{ key = "<", cmd = "<gv", desc = "Reselect after indent", mode = "v" },
	{ key = ">", cmd = ">gv", desc = "Reselect after indent", mode = "v" },
	{ key = "J", cmd = ":m '>+1<CR>gv=gv", desc = "Move line down", mode = "v" },
	{ key = "K", cmd = ":m '<-2<CR>gv=gv", desc = "Move line up", mode = "v" },
}
--}}}

--{{{ Buffer Navigation Mappings
local buffer_navigation_mappings = {
	{ key = "<C-J>", cmd = ":bnext<CR>", desc = "Next buffer", mode = "n" },
	{ key = "<C-K>", cmd = ":bprev<CR>", desc = "Previous buffer", mode = "n" },
	{ key = "<leader>bb", cmd = ":Telescope buffers<CR>", desc = "List buffers", mode = "n" },
	{ key = "<leader>bk", cmd = ":bdelete<CR>", desc = "Delete buffer", mode = "n" },
	{ key = "<leader>bn", cmd = ":bnext<CR>", desc = "Next buffer", mode = "n" },
	{ key = "<leader>bp", cmd = ":bprev<CR>", desc = "Previous buffer", mode = "n" },
}
--}}}

--{{{ Terminal Mappings
local terminal_mappings = {
	-- {
	-- 	key = "op",
	-- 	cmd = "<C-\\><C-N>:ToggleTerm name=ipython",
	-- 	desc = "Open IPython",
	-- 	mode = "v",
	-- 	group = "Open",
	-- },
	-- {
	-- 	key = "oP",
	-- 	cmd = "<C-\\><C-N>:ToggleTerm name=ipython-full",
	-- 	desc = "Open full IPython",
	-- 	mode = "v",
	-- 	group = "Open",
	-- },
	{
		key = "<C-T>",
		cmd = ":ToggleTerm name=toggleterm<CR>",
		desc = "Toggle terminal",
		mode = "n",
	},
	{
		key = "<leader>tt",
		cmd = ":ToggleTerm name=toggleterm<CR>",
		desc = "Toggle terminal",
		mode = "n",
	},
	{
		key = "<leader>tT",
		cmd = ":ToggleTerm name=toggleterm-full direction=tab<CR>",
		desc = "Toggle full terminal",
		mode = "n",
	},
	{
		key = "<leader>ot",
		cmd = ":ToggleTerm name=toggleterm<CR>",
		desc = "Open terminal",
		mode = "n",
	},
	{
		key = "<leader>oT",
		cmd = ":ToggleTerm name=toggleterm-full direction=tab<CR>",
		desc = "Open full terminal",
		mode = "n",
	},
	{
		key = "<leader>ts",
		cmd = ":TermSelect<CR>",
		desc = "Select terminal",
		mode = "n",
	},
	{
		key = "<leader>tv",
		cmd = ":ToggleTerm direction=vertical name=toggleterm-vert<CR>",
		desc = "Toggle vertical terminal",
		mode = "n",
	},
	{
		key = "<leader>th",
		cmd = ":ToggleTerm direction=horizontal name=toggleterm-hori<CR>",
		desc = "Toggle horizontal terminal",
		mode = "n",
	},
	{
		key = "<leader>ov",
		cmd = ":ToggleTerm direction=vertical name=toggleterm-vert<CR>",
		desc = "Open vertical terminal",
		mode = "n",
	},
	{
		key = "<leader>oh",
		cmd = ":ToggleTerm direction=horizontal name=toggleterm-hori<CR>",
		desc = "Open horizontal terminal",
		mode = "n",
	},
	{
		key = "<leader>tf",
		cmd = ":ToggleTerm name=toggleterm<CR>",
		desc = "Toggle terminal",
		mode = "n",
	},
	{
		key = "<leader>-",
		cmd = ":ToggleTerm direction='horizontal'<CR>",
		desc = "Toggle horizontal terminal",
		mode = "n",
	},
	{
		key = "<leader>|",
		cmd = ":ToggleTerm direction='vertical'<CR>",
		desc = "Toggle vertical terminal",
		mode = "n",
	},
}
--}}}

-- {{{ LSP Mappings
local lsp_mappings = {
	{ mode = "n", key = "gA", cmd = vim.lsp.buf.code_action, group = "Code Action" },
	{ mode = "n", key = "gd", cmd = ":Telescope lsp_definitions<CR>", group = "LSP Definitions" },
	{ mode = "n", key = "gDc", cmd = ":Telescope lsp_implementations<CR>", group = "LSP Implementations" },
	{ mode = "n", key = "gDf", cmd = ":Telescope lsp_definitions<CR>", group = "LSP Definitions" },
	{ mode = "n", key = "gF", cmd = ":edit <cfile><CR>", group = "Edit File" },
	{ mode = "n", key = "gT", cmd = ":Telescope lsp_type_definitions<CR>", group = "LSP Type Definitions" },
	{ mode = "n", key = "gb", cmd = ":Gitsigns blame_line<CR>", group = "Blame Line" },
	{ mode = "n", key = "<leader>gb", cmd = ":Gitsigns blame<CR>", group = "Git Blame" },
	{ mode = "n", key = "gi", cmd = ":Telescope lsp_implementations<CR>", group = "Telescope Implementations" },
	{ mode = "n", key = "gj", cmd = ":Telescope jumplist<CR>", group = "Telescope Jumplist" },
	{ mode = "n", key = "gr", cmd = ":Telescope lsp_references<CR>", goup = "LSP References" },
	{ mode = "n", key = "gs", cmd = vim.lsp.buf.signature_help },
	-- { mode = "n", key = "K", cmd = vim.lsp.buf.hover },
	{ mode = "n", key = "<leader>ca", cmd = vim.lsp.buf.code_action, group = "Code" },
	{ mode = "n", key = "<leader>ch", cmd = ":lua vim.lsp.buf.signature_help()<CR>", group = "Signature Help" },
	{ mode = "n", key = "<leader>cR", cmd = ":lua vim.lsp.buf.rename()<CR>", group = "Rename" },
	{ mode = "n", key = "<leader>cr", cmd = ":Telescope lsp_references<CR>", group = "LSP References" },
	{ mode = "n", key = "<leader>cs", cmd = ":Telescope lsp_document_symbols<CR>", group = "LSP Document Symbols" },
	{ mode = "n", key = "<leader>ct", cmd = ":Telescope lsp_type_definitions<CR>", group = "LSP Definitions" },
	{
		mode = "n",
		key = "<leader>cw",
		cmd = ":Telescope lsp_dynamic_workspace_symbols<CR>",
		group = "LSP Workspace Symbols",
	},
	{ mode = "n", key = "<leader>ci", cmd = ":Telescope lsp_implementations<CR>", group = "LSP Implementations" },
	{ mode = "n", key = "<leader>cci", cmd = ":Telescope lsp_incoming_calls<CR>", group = "LSP Incoming Calls" },
	{ mode = "n", key = "<leader>cco", cmd = ":Telescope lsp_outgoing_calls<CR>", group = "LSP Outgoing Calls" },
	{
		mode = "n",
		key = "<leader>cd",
		cmd = ":Telescope diagnostics theme=dropdown layout_config={width=0.8}<CR>",
		group = "Telecope Diagnostics",
	},
	{
		mode = "n",
		key = "<leader>cDs",
		cmd = ":Telescope diagnostics theme=dropdown layout_config={width=0.8}<CR>",
		group = "Telecope Diagnostics",
	},
	{ mode = "n", key = "<leader>cDn", cmd = ":lua vim.diagnostic.goto_next()<CR>", group = "Goto Next Preview" },
	{
		mode = "n",
		key = "<leader>cDp",
		cmd = ":lua vim.diagnostic.goto_prev()<CR<CR>",
		group = "Goto Previous Preview",
	},
	{ mode = "n", key = "<leader>cl", cmd = ":lua vim.diagnostic.setloclist()<CR>", group = "Set Loclist" },
	{
		mode = "n",
		key = "<leader>cPs",
		cmd = function()
			vim.cmd("!pyright --createstub " .. vim.fn.expand("<cword>"))
		end,
		group = "Generate Stub File",
	},
}
-- }}}

-- {{{ Code Companion Mappings
local code_companion_mappings = {
	{ mode = "n", key = "<leader>cp", cmd = ":vert Copilot panel<CR>", group = "Copilot Panel" },
	{ mode = "n", key = "<leader>oc", cmd = ":CodeCompanionChat Toggle<CR>", group = "Toggle Codecompanion" },
	{ mode = "n", key = "<leader>Cc", cmd = ":CodeCompanionChat Toggle<CR>", group = "Toggle Codecompanion" },
	{
		mode = "n",
		key = "<leader>Ci",
		cmd = ":CodeCompanion #{buffer} ",
		group = "Inline CodeCompanion",
		opts = nosilent,
	},
	{ mode = "n", key = "<leader>CT", cmd = ":CodeCompanionChat Toggle<CR>", group = "CodeCompanion Toggle" },
	{ mode = "n", key = "<leader>Ca", cmd = ":CodeCompanionActions<CR>", group = "CodeCompanion Actions" },
	{ mode = "v", key = "<leader>Cc", cmd = ":CodeCompanionChat Add<CR>", group = "CodeCompanion Add" },
	{
		mode = "v",
		key = "<leader>Ci",
		cmd = ":CodeCompanion #{buffer} ",
		group = "CodeCompanion #{buffer}",
		opts = nosilent,
	},
	{ mode = "v", key = "<leader>Ce", cmd = ":CodeCompanion /explain<CR>", group = "CodeCompanion /explain" },
	{ mode = "v", key = "<leader>Cf", cmd = ":CodeCompanion /fix<CR>", group = "CodeCompanion /fix" },
	{ mode = "v", key = "<leader>Cl", cmd = ":CodeCompanion /lsp<CR>", group = "CodeCompanion /lsp" },
	{ mode = "v", key = "<leader>Ct", cmd = ":CodeCompanion /tests<CR>", group = "CodeCompanion /tests" },
}
-- }}}

-- {{{ Telescope mappings
local telescope_mappings = {
	{
		mode = "n",
		key = "//",
		cmd = ":Telescope current_buffer_fuzzy_find previewer=false<CR>",
		"Current buffer fuzzy find",
	},
	{
		mode = "n",
		key = "??",
		cmd = ":Telescope lsp_document_symbols theme=dropdown layout_config={width=0.5}<CR>",
		group = "Lsp document symbols",
	},
	{
		mode = "n",
		key = "<leader>fc",
		cmd = ':Telescope color_names theme=dropdown layout_config={width=0.45,height=25,prompt_position="bottom"} layout_strategy=vertical<CR>',
		group = "Telescope color names",
	},
	{
		mode = "n",
		key = "<leader>Tc",
		cmd = ":Telescope colorscheme<CR>",
		group = "Telescope colorscheme",
	},
	{
		mode = "n",
		key = "<leader>TC",
		cmd = ':Telescope color_names theme=dropdown layout_config={width=0.45,height=25,prompt_position="bottom"} layout_strategy=vertical<CR>',
		group = "Telescope color names",
	},
	{
		mode = "n",
		key = "<leader>Tn",
		cmd = ":Telescope notify theme=dropdown layout_config={width=0.75}<CR>",
		group = "Telescope notify",
	},
	{
		mode = "n",
		key = "<leader>TN",
		cmd = ":Telescope noice theme=dropdown layout_config={width=0.75}<CR>",
		group = "Telescope Noice",
	},
	{
		mode = "n",
		key = "<leader>ff",
		cmd = ":Telescope find_files find_command=rg,--ignore,--follow,--hidden,--files prompt_prefix=🔍<CR>",
		group = "Find files",
	},
	{ mode = "n", key = "<leader>fg", cmd = ":Telescope live_grep<CR>", group = "Live Grep" },
	{
		mode = "n",
		key = "<leader>Tg",
		cmd = ':Telescope glyph theme=dropdown layout_config={width=0.45,height=35,prompt_position="bottom"} layout_strategy=vertical<CR>',
		group = "Telescope Glyph",
	},
	{
		mode = "n",
		key = "<leader>fG",
		cmd = ':Telescope glyph theme=dropdown layout_config={width=0.45,height=35,prompt_position="bottom"} layout_strategy=vertical<CR>',
		group = "Glhph",
	},
	{ mode = "n", key = "<leader>fb", cmd = ":Telescope file_browser<CR>", group = "File browser" },
	{
		mode = "n",
		key = "<leader>fr",
		cmd = ":Telescope oldfiles theme=dropdown layout_config={width=0.5}<CR>",
		group = "Oldfiles",
	},
	{
		mode = "n",
		key = "<leader>hc",
		cmd = ":Telescope commands<CR>",
		group = "Commands",
	},
	{
		mode = "n",
		key = "<leader>hv",
		cmd = ":Telescope vim_options<CR>",
		group = "Vim options",
	},
	{
		mode = "n",
		key = "<leader>hk",
		cmd = ":Telescope keymaps<CR>",
		group = "Keymaps",
	},
	{
		mode = "n",
		key = "<leader>hs",
		cmd = ":Telescope spell_suggest<CR>",
		group = "Spell suggest",
	},
	{
		mode = "n",
		key = "<leader>ht",
		cmd = ":Telescope help_tags<CR>",
		group = "Help tags",
	},
	{
		mode = "n",
		key = "<leader>hm",
		cmd = ":Telescope man_pages theme=dropdown layout_config={width=0.75}<CR>",
		group = "Man pages",
	},
	{
		mode = "n",
		key = "<leader>sf",
		cmd = ":Telescope find_files find_command=rg,--ignore,--follow,--hidden,--files prompt_prefix=🔍<CR>",
		group = "Search files",
	},
	{ mode = "n", key = "<leader>sF", cmd = ":Telescope fidget<CR>", group = "Fidget" },
	{ mode = "n", key = "<leader>sg", cmd = ":Telescope live_grep<CR>", group = "Live grep" },
	{ mode = "n", key = "<leader>sh", cmd = ":Telescope command_history<CR>", group = "Command history" },
	{ mode = "n", key = "<leader>sm", cmd = ":Telescope man_pages<CR>", group = "Man pages" },
	{ mode = "n", key = "<leader>s/", cmd = ":Telescope search_history<CR>", group = "Search history" },
	{ mode = "n", key = "<leader>gc", cmd = ":Telescope git_commits<CR>", group = "Git commits" },
	{ mode = "n", key = "<leader>gf", cmd = ":Telescope git_files<CR>", group = "Git files" },
	{ mode = "n", key = "<leader>Tr", cmd = ":Telescope reloader<CR>", group = "Telescope reloader" },
}
--}}}

-- {{{ File Explorer Mappings (i guess)
local file_explorer_mappings = {
	{ mode = "n", key = "<leader>nt", cmd = ":NvimTreeToggle<CR>" },
	{ mode = "n", key = "<leader>nc", cmd = ":lua require('notify').dismiss()<CR>" },
	{ mode = "n", key = "<leader>D", cmd = ":Dotenv .env<CR>", group = "Dotenv" },
}
-- }}}

-- {{{ Misc Utilities Mappings
local misc_utilities_mappings = {
	{ mode = "n", key = "<leader>x", cmd = "<cmd>!chmod +x %<CR>", group = "Make Executable" },
	{ mode = "n", key = "<leader>y", cmd = '"+', group = "System Yank" },
	{ mode = "v", key = "<leader>y", cmd = '"+', group = "System Yank" },
	{ mode = "n", key = "<leader>sc", cmd = ":nohls<CR>", group = "Search" },
}
-- }}}

-- {{{ Goto Preview Mappings
local goto_preview_mappings = {
	{ mode = "n", key = "gpc", cmd = ':lua require("goto-preview").close_all_win()<CR>', group = "Goto Preview" },
	{
		mode = "n",
		key = "gpd",
		cmd = ':lua require("goto-preview").goto_preview_definition()<CR>',
		group = "Goto Preview",
	},
	{
		mode = "n",
		key = "gpi",
		cmd = ':lua require("goto-preview").goto_preview_implementation()<CR>',
		group = "Goto Preview",
	},
}
-- }}}

-- {{{ Workspace Management Mappings
local workspace_management_mappings = {
	{ mode = "n", key = "<leader>wa", cmd = vim.lsp.buf.add_workspace_folder },
	{ mode = "n", key = "<leader>wr", cmd = vim.lsp.buf.remove_workspace_folder },
	{
		mode = "n",
		key = "<leader>wl",
		cmd = function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end,
	},
}
-- }}}

-- {{{ Noice Mappings
local noice_mappings = {
	{ mode = "n", key = "<leader>Nh", cmd = ":Noice telescope<CR>", group = "Noice" },
	{ mode = "n", key = "<leader>Nl", cmd = ":Noice last<CR>", group = "Noice" },
	{ mode = "n", key = "<leader>Nd", cmd = ":Noice dismiss<CR>", group = "Noice" },
	{ mode = "n", key = "<leader>Ne", cmd = ":Noice errors<CR>", group = "Noice" },
	{ mode = "n", key = "<leader>Ns", cmd = ":Noice stats<CR>", group = "Noice" },
}
-- }}}

-- {{{ ODIS Mappings
local odis_mappings = {
	{
		mode = "n",
		key = "<leader>dv",
		cmd = ':lua require("odis").show_documentation("vsplit")<CR>',
		group = "Vertical split",
	},
	{ mode = "n", key = "<leader>dh", cmd = ':lua require("odis").show_documentation("split")<CR>', group = "Split" },
	{ mode = "n", key = "<leader>db", cmd = ':lua require("odis").show_documentation("buffer")<CR>', group = "Buffer" },
	{ mode = "n", key = "<leader>dt", cmd = ':lua require("odis").show_documentation("tab")<CR>', group = "Tab" },
	{ mode = "n", key = "<leader>df", cmd = ':lua require("odis").show_documentation("float")<CR>', group = "Float" },
}
-- }}}

-- {{{ Diffview Mappings
local diffview_mappings = {
	{

		mode = "n",
		key = "<leader>gdo",
		cmd = ":DiffviewOpen<CR>",
		group = "DiffviewOpen",
	},
	{

		mode = "n",
		key = "<leader>gdf",
		cmd = ":DiffviewFileHistory %<CR>",
		group = "Git",
	},
	{

		mode = "n",
		key = "<leader>gdh",
		cmd = ":DiffviewHistory<CR>",
		group = "Git",
	},
	{

		mode = "n",
		key = "<leader>gdc",
		cmd = ":DiffviewClose<CR>",
		group = "Git",
	},
	{

		mode = "n",
		key = "<leader>gdt",
		cmd = ":DiffviewToggleFiles<CR>",
		group = "Git",
		desc = "Toggle files view",
	},
	{

		mode = "n",
		key = "<leader>gdr",
		cmd = ":DiffviewRefresh<CR>",
		desc = "Refresh diffview",
		group = "Git",
	},
}
-- }}}

--{{{ Custom Terminals
local programs_map = {
	gg = { cmd = "lazygit", display_name = "lazygit", direction = "tab", hidden = true },
	op = { cmd = "ipython", display_name = "ipython", direction = "vertical", hidden = true },
	oP = {
		cmd = "ipython",
		display_name = "ipython-full",
		direction = "tab",
		hidden = true,
	},
	oi = { cmd = "sudo iotop", display_name = "iotop", direction = "tab", hidden = true },
	on = { cmd = "rmpc", display_name = "rmpc", direction = "tab", hidden = true },
	oN = { cmd = "nvtop", display_name = "nvtop", direction = "tab", hidden = true },
	ob = { cmd = "/usr/bin/btop", display_name = "btop", direction = "tab", hidden = true },
	od = { cmd = "lazydocker", display_name = "lazydocker", direction = "tab", hidden = true },
}

local temp
local tbl = {}
for key, value in pairs(programs_map) do
	temp = {
		cmd = function()
			term_toggle(term_factory(value))
		end,
		key = "<leader>" .. key,
		group = value.group,
		mode = "n",
		desc = "Open " .. value.display_name,
	}
	table.insert(tbl, temp)
end
add_to_whichkey(tbl, { key = "<leader>o", group = "Open" })

function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	map("t", "<esc>", [[<C-\><C-n>]], opts)
	map("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
--}}}

-- {{{ NVIM-IMAGE
local image_mappings = {
	{

		mode = "n",
		key = "<leader>id",
		cmd = ":lua require('image').disable()<CR>",
		desc = "Disable image rendering",
	},
	{

		mode = "n",
		key = "<leader>ie",
		cmd = ":lua require('image').enable()<CR>",
		desc = "Enable image rendering",
	},
}
-- }}}

--{{{ Groups
add_to_whichkey(nil, { key = "<leader>a", group = "AnyJump" })
add_to_whichkey(nil, { key = "<leader>b", group = "Buffers" })
add_to_whichkey(nil, { key = "<leader>c", group = "Code" })
add_to_whichkey(nil, { key = "<leader>ca", group = "Code Actions" })
add_to_whichkey(nil, { key = "<leader>cc", group = "Calls" })
add_to_whichkey(nil, { key = "<leader>C", group = "CodeCompanion" })
add_to_whichkey(nil, { key = "<leader>d", group = "ODIS" })
add_to_whichkey(nil, { key = "<leader>f", group = "Find" })
add_to_whichkey(nil, { key = "<leader>g", group = "Git" })
add_to_whichkey(nil, { key = "<leader>gd", group = "DiffView" })
add_to_whichkey(nil, { key = "<leader>h", group = "Help" })
add_to_whichkey(nil, { key = "<leader>i", group = "Image" })
add_to_whichkey(nil, { key = "<leader>j", group = "AnyJump" })
add_to_whichkey(nil, { key = "<leader>N", group = "Noice" })
-- add_to_whichkey(nil, { key = "<leader>o", group = "Open" })
add_to_whichkey(nil, { key = "<leader>p", group = "Paste in Place" })
add_to_whichkey(nil, { key = "<leader>s", group = "Search" })
add_to_whichkey(nil, { key = "<leader>t", group = "Terminal" })
add_to_whichkey(nil, { key = "<leader>T", group = "Telescope" })
add_to_whichkey(nil, { key = "<leader>w", group = "Workspace" })
add_to_whichkey(nil, { key = "<leader>x", group = "Make Executable" })
add_to_whichkey(nil, { key = "<leader>y", group = "System Yank" })
add_to_whichkey(nil, { key = "<leader>0", group = "Horizontal Terminal" })
add_to_whichkey(nil, { key = "<leader>cP", group = "Python" })
--}}}

--{{{ Whichkey Mappings
local mappings_tables = {
	basic_mappings,
	buffer_navigation_mappings,
	terminal_mappings,
	lsp_mappings,
	code_companion_mappings,
	telescope_mappings,
	file_explorer_mappings,
	misc_utilities_mappings,
	goto_preview_mappings,
	workspace_management_mappings,
	noice_mappings,
	odis_mappings,
	diffview_mappings,
	image_mappings,
}

for _, mapping in ipairs(mappings_tables) do
	add_to_whichkey(map_from_table(mapping))
end
add_to_whichkey(nil, { key = "<leader>dc", group = "Close" })
--}}}
