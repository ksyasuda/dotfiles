local M = {}

function M.term_toggle(term)
	if term then
		term:toggle()
	end
end

return M
