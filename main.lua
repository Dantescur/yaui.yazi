--- @since 25.2.7

-- Toggle the UI on/off.
local toggle_ui = ya.sync(function(self)
	if self.children then
		Modal:children_remove(self.children)
		self.children = nil
	else
		self.children = Modal:children_add(self, 10)
	end
	ya.render()
end)

-- Subscribe to a channel (here using "yaui") so that if a refresh is requested,
-- the manager emits a plugin refresh event.
local subscribe = ya.sync(function(self)
	ps.unsub("yaui")
	ps.sub("yaui", function()
		ya.manager_emit("plugin", { self._id, "refresh" })
	end)
end)

local M = {
	keys = {
		{ on = "q", run = "quit" },
	},
}

-- Instantiate the plugin and layout a centered square UI.
function M:new(area)
	self:layout(area)
	return self
end

-- Layout: split the given area into thirds horizontally and vertically,
-- then use the center chunk as a square.
function M:layout(area)
	local hChunks = ui.Layout()
		:constraints({
			ui.Constraint.Percentage(25),
			ui.Constraint.Percentage(50),
			ui.Constraint.Percentage(25),
		})
		:split(area)
	local vChunks = ui.Layout()
		:constraints({
			ui.Constraint.Percentage(25),
			ui.Constraint.Percentage(50),
			ui.Constraint.Percentage(25),
		})
		:split(hChunks[2])
	self._area = vChunks[2]
end

-- Entry: if the job is a refresh, simply re-render.
-- Otherwise, toggle the UI, subscribe to events, and listen for key events.
function M:entry(job)
	if job.args[1] == "refresh" then
		return ya.render()
	end

	toggle_ui(self)
	subscribe(self)

	local tx, rx = ya.chan("mpsc")

	local function producer()
		while true do
			local cand = self.keys[ya.which({ cands = self.keys, silent = true })] or { run = {} }
			for _, action in ipairs(type(cand.run) == "table" and cand.run or { cand.run }) do
				tx:send(action)
				if action == "quit" then
					toggle_ui(self)
					return
				end
			end
		end
	end

	local function consumer()
		while true do
			local action = rx:recv()
			if action == "quit" then
				break
			end
		end
	end

	ya.join(producer, consumer)
end

-- Redraw: clear the square area and draw a bordered box with a centered title.
function M:redraw()
	return {
		ui.Clear(self._area),
		ui.Border(ui.Border.ALL)
			:area(self._area)
			:type(ui.Border.ROUNDED)
			:style(ui.Style():fg("blue"))
			:title(ui.Line("Yaui"):align(ui.Line.CENTER)),
	}
end

function M:reflow()
	return { self }
end

return M
