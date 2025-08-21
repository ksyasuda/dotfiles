require("core.lazy")
vim.cmd("colorscheme catppuccin")
require("core.keymaps")
-- require("core.lsp-notifications")
require("utils.extensions")
require("utils.telescope_extra").setup()
require("utils.git_paste").setup({ telescope_key = "<leader>pg" })
require("utils.treesitter.parsers.hyprlang")
require("utils.hyprland.lsp")
-- vim.notify = function(msg, level, opts)
-- 	print("Notification debug:", msg, level, vim.inspect(opts))
-- 	-- Call original notify
-- 	require("notify")(msg, level, opts)
-- end
