-- lspkind.lua
local lspkind = require("lspkind")
lspkind.init({
  preset = 'default',
  symbol_map = {
    Copilot = "",
    Function = "󰊕",
    Text = "󰊄",
    Method = "󰆧",
    Operator = "󰆕",
    Keyword = "󰌋",
    Variable = "󰂡",
    Field = "󰇽",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "",
    Value = "󰎠",
    Enum = "",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "",
    Event = "",
    TypeParameter = "󰅲",
  },
})
vim.api.nvim_set_hl(0, "CmpItemKindCopilot", {fg ="#6CC644"})
