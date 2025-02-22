--- @since 25.2.7

local toggle_ui = ya.sync(function(self)
	if self.children then
		Modal:children_remove(self.children)
		self.children = nil
	else
		self.children = Modal:children_add(self, 10)
	end
	ya.render()
end)

local M = {
	keys = {
		{ on = "q", run = "quit" },
	},
}

-- Create a new instance and calculate a centered square area.
function M:new(area)
	self:layout(area)
	return self
end

-- Layout: split the provided area into thirds horizontally and vertically,
-- then use the center chunk to form a square.
function M:layout(area)
	local hChunks = ui.Layout()
		:constraints({ ui.Constraint.Percentage(25), ui.Constraint.Percentage(50), ui.Constraint.Percentage(25) })
		:split(area)
	local vChunks = ui.Layout()
		:constraints({ ui.Constraint.Percentage(25), ui.Constraint.Percentage(50), ui.Constraint.Percentage(25) })
		:split(hChunks[2])
	self._area = vChunks[2]
end

-- Entry point: toggle the UI and listen for key events.
function M:entry(job)
	toggle_ui(self)
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

-- Redraw: clear the area and draw a square border with a centered title.
function M:redraw()
	return {
		ui.Clear(self._area),
		ui.Border(ui.Border.ALL):area(self._area):type(ui.Border.ROUNDED):title(ui.Line("Yaui"):align(ui.Line.CENTER)),
	}
end

function M:reflow()
	return { self }
end

return M
