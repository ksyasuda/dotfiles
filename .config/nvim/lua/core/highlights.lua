local catppuccin = require("catppuccin.palettes").get_palette("macchiato")
local sethl = vim.api.nvim_set_hl
-- Customization for Pmenu
sethl(0, "PmenuSel", { bg = "#282C34", fg = "NONE" })
sethl(0, "Pmenu", { fg = "#C5CDD9", bg = "dodgerblue" })

sethl(0, "CmpItemAbbrDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
sethl(0, "CmpItemAbbrMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
sethl(0, "CmpItemAbbrMatchFuzzy", { fg = "#82AAFF", bg = "NONE", bold = true })
sethl(0, "CmpItemMenu", { fg = "#C792EA", bg = "NONE", italic = true })

sethl(0, "CmpItemKindField", { fg = "#EED8DA", bg = "#B5585F" })
sethl(0, "CmpItemKindProperty", { fg = "#EED8DA", bg = "#B5585F" })
sethl(0, "CmpItemKindEvent", { fg = "#EED8DA", bg = "#B5585F" })

sethl(0, "CmpItemKindText", { fg = "#C3E88D", bg = "#9FBD73" })
sethl(0, "CmpItemKindEnum", { fg = "#C3E88D", bg = "#9FBD73" })
sethl(0, "CmpItemKindKeyword", { fg = "#C3E88D", bg = "#9FBD73" })

sethl(0, "CmpItemKindConstant", { fg = "#FFE082", bg = "#D4BB6C" })
sethl(0, "CmpItemKindConstructor", { fg = "#FFE082", bg = "#D4BB6C" })
sethl(0, "CmpItemKindReference", { fg = "#FFE082", bg = "#D4BB6C" })

sethl(0, "CmpItemKindFunction", { fg = "#EADFF0", bg = "#A377BF" })
sethl(0, "CmpItemKindStruct", { fg = "#EADFF0", bg = "#A377BF" })
sethl(0, "CmpItemKindClass", { fg = "#EADFF0", bg = "#A377BF" })
sethl(0, "CmpItemKindModule", { fg = "#EADFF0", bg = "#A377BF" })
sethl(0, "CmpItemKindOperator", { fg = "#EADFF0", bg = "#A377BF" })

sethl(0, "CmpItemKindVariable", { fg = "#C5CDD9", bg = "#7E8294" })
sethl(0, "CmpItemKindFile", { fg = "#C5CDD9", bg = "#7E8294" })

sethl(0, "CmpItemKindUnit", { fg = "#F5EBD9", bg = "#D4A959" })
sethl(0, "CmpItemKindSnippet", { fg = "#F5EBD9", bg = "#D4A959" })
sethl(0, "CmpItemKindFolder", { fg = "#F5EBD9", bg = "#D4A959" })

sethl(0, "CmpItemKindMethod", { fg = "#DDE5F5", bg = "#6C8ED4" })
sethl(0, "CmpItemKindValue", { fg = "#DDE5F5", bg = "#6C8ED4" })
sethl(0, "CmpItemKindEnumMember", { fg = "#DDE5F5", bg = "#6C8ED4" })

sethl(0, "CmpItemKindInterface", { fg = "#D8EEEB", bg = "#58B5A8" })
sethl(0, "CmpItemKindColor", { fg = "#D8EEEB", bg = "#58B5A8" })
sethl(0, "CmpItemKindTypeParameter", { fg = "#D8EEEB", bg = "#58B5A8" })

sethl(0, "FloatBorder", { fg = "#8aadf4", bold = true })
sethl(0, "LspSignatureActiveParameter", { fg = "#89b4fa", bg = "NONE", bold = true })
sethl(0, "CmpBorder", { fg = "#8aadf4", bold = true })
sethl(0, "CmpDocBorder", { fg = "#8aadf4", bold = true })
sethl(0, "SnacksIndent1", { fg = catppuccin.red })
sethl(0, "SnacksIndent3", { fg = catppuccin.peach })
sethl(0, "SnacksIndent4", { fg = catppuccin.yellow })
sethl(0, "SnacksIndent5", { fg = catppuccin.green })
sethl(0, "SnacksIndent6", { fg = catppuccin.sky })
sethl(0, "SnacksIndent7", { fg = catppuccin.blue })
sethl(0, "SnacksIndent8", { fg = catppuccin.mauve })
