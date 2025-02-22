--- @since 1.0.0
-- Minimal bootstrap for YA Plugin Manager for Yazi with hardcoded data

local ya = require("ya")
local ui = require("ui")

-- Toggle the plugin manager UI (optional, for showing/hiding)
local toggle_ui = ya.sync(function(self)
	if self.children then
		Modal:children_remove(self.children)
		self.children = nil
	else
		self.children = Modal:children_add(self, 10)
	end
	ya.render()
end)

-- Update the list with hardcoded plugin data
local update_plugins = ya.sync(function(self)
	self.plugins = {
		{ name = "Plugin Alpha", version = "1.0.0", status = "active" },
		{ name = "Plugin Beta", version = "1.2.3", status = "inactive" },
		{ name = "Plugin Gamma", version = "0.9.5", status = "active" },
	}
	self.cursor = 0
	ya.render()
end)

-- Update the selection cursor with boundary checking
local update_cursor = ya.sync(function(self, offset)
	if #self.plugins == 0 then
		self.cursor = 0
	else
		self.cursor = ya.clamp(0, self.cursor + offset, #self.plugins - 1)
	end
	ya.render()
end)

-- Define keybindings for navigation and actions
local M = {
	keys = {
		{ on = "q", run = "quit" },
		{ on = "k", run = "up" },
		{ on = "j", run = "down" },
		{ on = "<Up>", run = "up" },
		{ on = "<Down>", run = "down" },
		{ on = "r", run = "refresh" },
		{ on = "Enter", run = { "select", "quit" } },
	},
}

-- Create a new instance and set up the layout
function M:new(area)
	self:layout(area)
	return self
end

-- Set up a centered layout for the plugin list
function M:layout(area)
	local chunks = ui.Layout()
		:constraints({
			ui.Constraint.Percentage(20),
			ui.Constraint.Percentage(60),
			ui.Constraint.Percentage(20),
		})
		:split(area)
	self._area = chunks[2]
end

-- Entry point: process key events and initialize the plugin list
function M:entry(job)
	if job.args[1] == "refresh" then
		return update_plugins(self)
	end

	-- Load hardcoded plugins initially
	update_plugins(self)

	local tx, rx = ya.chan("mpsc")

	-- Producer: captures key events and sends corresponding actions
	function producer()
		while true do
			local cand = self.keys[ya.which({ cands = self.keys, silent = true })] or { run = {} }
			for _, action in ipairs(type(cand.run) == "table" and cand.run or { cand.run }) do
				tx:send(action)
				if action == "quit" then
					return
				end
			end
		end
	end

	-- Consumer: processes actions such as navigation and selection
	function consumer()
		repeat
			local action = rx:recv()
			if action == "quit" then
				break
			elseif action == "up" then
				update_cursor(self, -1)
			elseif action == "down" then
				update_cursor(self, 1)
			elseif action == "select" then
				local plugin = self.plugins[self.cursor + 1]
				if plugin then
					-- For now, just notify the selected plugin name
					ya.notify({ title = "Plugin Selected", content = plugin.name, timeout = 3 })
				end
			elseif action == "refresh" then
				update_plugins(self)
			end
		until false
	end

	ya.join(producer, consumer)
end

-- Redraw the UI with a bordered table listing plugins
function M:redraw()
	local rows = {}
	for i, plugin in ipairs(self.plugins or {}) do
		local style = (i - 1 == self.cursor) and ui.Style():fg("blue"):underline() or ui.Style()
		rows[#rows + 1] = ui.Row({ plugin.name, plugin.version, plugin.status }):style(style)
	end

	return {
		ui.Clear(self._area),
		ui.Border(ui.Border.ALL)
			:area(self._area)
			:type(ui.Border.ROUNDED)
			:style(ui.Style():fg("green"))
			:title(ui.Line("YA Plugin Manager"):align(ui.Line.CENTER)),
		ui.Table(rows)
			:area(self._area:pad(ui.Pad(1, 2, 1, 2)))
			:header(ui.Row({ "Name", "Version", "Status" }):style(ui.Style():bold()))
			:row(self.cursor)
			:widths({
				ui.Constraint.Percentage(40),
				ui.Constraint.Percentage(30),
				ui.Constraint.Percentage(30),
			}),
	}
end

function M:reflow()
	return { self }
end

return M
