local g = vim.g
local o = vim.o
local A = vim.api
local l = vim.lsp

g.mapleader = " "
g.maplocalleader = ","
g.fzf_command = 'fzf --height 90% --width=85% --layout=reverse --preview "bat --color=always {}"'
o.completeopt = "menu,menuone,noselect"
o.showmode = false
o.termguicolors = true
o.background = "dark"
o.mouse = "a"
o.syntax = "on"
o.laststatus = 3
o.number = true
o.relativenumber = true
o.colorcolumn = "88"
o.textwidth = 80
o.shiftwidth = 4
o.expandtab = true
o.tabstop = 4
o.autoindent = true
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true
o.title = true
o.splitright = true
o.cursorline = true
o.scrolloff = 8
o.sidescrolloff = 8
o.wildmenu = false --cmp
o.wildmode = "" --cmp
o.wildoptions = ""
o.wildignore = ".git,.hg,.svn,CVS,.DS_Store,.idea,.vscode,.vscode-test,node_modules"
o.showmatch = true
o.list = true
o.listchars = "tab:»·,trail:·,nbsp:·,extends:>,precedes:<"
o.encoding = "utf-8"
o.guifont = "JetBrainsMono Nerd Font 14"
o.expandtab = true
o.hidden = true
o.cmdheight = 1
o.updatetime = 300
o.timeoutlen = 500
o.pumwidth = 35
o.foldmethod = "marker"
o.conceallevel = 1
g.db_ui_use_nerd_fonts = 1

-- vim.cmd.colorscheme = 'catppuccin-macchiato'
vim.cmd.colorscheme = "catppuccin"

-- Define the highlight color for float border
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89b4fa", bold = true })

local border = {
	{ "╭", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "╮", "FloatBorder" },
	{ "│", "FloatBorder" },
	{ "╯", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "╰", "FloatBorder" },
	{ "│", "FloatBorder" },
}

-- set border for floating windows and signature help
-- UNSUPPPORTED: https://github.com/neovim/neovim/issues/32242#issuecomment-2777120640
-- l.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
-- l.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
o.winborder = "rounded"

vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	underline = true,
	float = { border = "rounded", source = true },
	severity_sort = true,
})
