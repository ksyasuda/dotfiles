local Terminal = require("toggleterm.terminal").Terminal
local notify = require("notify")
local M = {}

function M.term_factory(cfg)
	cfg["on_stderr"] = function(_, job, data, name)
		notify(name .. " encountered an error on job: " .. job .. "\nData: " .. data, "error")
	end
	return Terminal:new(cfg)
end

return M
