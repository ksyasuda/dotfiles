local notify = require("notify")
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_len = #spinner_frames -- cache spinner length
local M = {}
local timeout = 2999

-- Helper function to safely call notify
local function safe_notify(msg, level, opts)
	local ok, res = pcall(notify, msg, level, opts)
	return ok, res
end

function M:init()
	local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequestStarted",
		group = group,
		callback = function(request)
			local handle = M:create_progress_handle(request)
			M:store_progress_handle(request.data.id, handle)
		end,
	})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequestFinished",
		group = group,
		callback = function(request)
			local handle = M:pop_progress_handle(request.data.id)
			if handle then
				M:report_exit_status(handle, request)
				handle:finish()
			end
		end,
	})
end

M.handles = {}

function M:store_progress_handle(id, handle)
	M.handles[id] = handle
end

function M:pop_progress_handle(id)
	local handle = M.handles[id]
	M.handles[id] = nil
	return handle
end

function M:create_progress_handle(request)
	local title = " Requesting assistance"
		.. " ("
		.. request.data.interaction
		.. ") from "
		.. request.data.adapter.formatted_name
		.. " using "
		.. request.data.adapter.model
	local idx = 1
	local start_time = os.time()
	local notification_id =
		notify(spinner_frames[idx] .. " In progress (" .. "0s" .. ")...", "info", { title = title, timeout = false })
	local handle = { notification_id = notification_id, title = title, finished = false }
	local timer = vim.loop.new_timer()
	timer:start(
		0,
		100,
		vim.schedule_wrap(function()
			if handle.finished then
				return
			end -- stop updating if finished
			idx = idx % spinner_len + 1
			local elapsed = os.difftime(os.time(), start_time)
			local opts = { replace = handle.notification_id, title = title, timeout = false }
			local ok, new_id = safe_notify(spinner_frames[idx] .. " In progress (" .. elapsed .. "s)...", "info", opts)
			if ok then
				handle.notification_id = new_id
			else
				handle.notification_id = notify(
					spinner_frames[idx] .. " In progress (" .. elapsed .. "s)...",
					"info",
					{ title = title, timeout = false }
				)
			end
		end)
	)
	handle.timer = timer
	handle.finish = function()
		handle.finished = true -- mark as finished to abort future updates
		if handle.timer then
			handle.timer:stop()
			handle.timer:close()
			handle.timer = nil
		end
	end
	return handle
end

function M:report_exit_status(handle, request)
	local title = handle.title
		or (
			" Requesting assistance"
			.. " ("
			.. request.data.strategy
			.. ") from "
			.. request.data.adapter.formatted_name
			.. " using "
			.. request.data.adapter.model
		)
	local function report(msg, level)
		local opts = { replace = handle.notification_id, title = title, timeout = timeout }
		local ok = safe_notify(msg, level, opts)
		if not ok then
			notify(msg, level, { title = title, timeout = timeout })
		end
	end

	if request.data.status == "success" then
		report("Completed", "info")
	elseif request.data.status == "error" then
		report(" Error", "error")
	else
		report("󰜺 Cancelled", "warn")
	end
end

return M
