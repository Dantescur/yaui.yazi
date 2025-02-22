--- my-plugin/init.lua
local M = {
	keys = {
		{ on = "q", run = "quit" },
		{ on = "k", run = "up" },
		{ on = "j", run = "down" },
		{ on = "l", run = "enter" },
	},
}

-- Plugin state management
local state = ya.sync(function(self)
	return {
		visible = false,
		cursor = 0,
		items = {}, -- Your plugin data
		status = "",
	}
end)

-- UI Toggle
local toggle_ui = ya.sync(function(self)
	if self.state.visible then
		Modal:children_remove(self.children)
		self.children = nil
	else
		self.children = Modal:children_add(self, 10) -- Z-index
		self:refresh_data() -- Initial data load
	end
	self.state.visible = not self.state.visible
	ya.render()
end)

-- Core plugin functions
function M:entry()
	toggle_ui(self)
	self:setup_handlers()
end

function M:setup_handlers()
	local tx, rx = ya.chan("mpsc")

	ya.thread(function() -- Producer
		while self.state.visible do
			local cand = self.keys[ya.which({ cands = self.keys, silent = true })]
			if cand then
				tx:send(cand.run)
				if cand.run == "quit" then
					break
				end
			end
		end
	end)

	ya.thread(function() -- Consumer
		repeat
			local action = rx:recv()
			if action == "up" then
				self.state.cursor = math.max(0, self.state.cursor - 1)
				ya.render()
			elseif action == "down" then
				self.state.cursor = math.min(#self.state.items - 1, self.state.cursor + 1)
				ya.render()
			elseif action == "enter" then
				self:handle_enter()
			end
		until action == "quit"
	end)
end

function M:refresh_data()
	-- Replace with your data loading logic
	self.state.items = {
		{ label = "Item 1", value = "1" },
		{ label = "Item 2", value = "2" },
		{ label = "Item 3", value = "3" },
	}
	ya.render()
end

function M:handle_enter()
	local selected = self.state.items[self.state.cursor + 1]
	if selected then
		self.state.status = "Selected: " .. selected.label
		ya.render()
	end
end

-- UI Rendering
function M:redraw()
	if not self.state.visible then
		return
	end

	local area = ya.layout().area
	local layout = ui.Layout()
		:direction(ui.Layout.VERTICAL)
		:constraints({
			ui.Constraint.Percentage(90),
			ui.Constraint.Percentage(10),
		})
		:split(area:pad(ui.Pad(1, 1, 1, 1)))

	-- Main content
	local rows = {}
	for i, item in ipairs(self.state.items) do
		rows[#rows + 1] = ui.Row({
			(i == self.state.cursor + 1) and "▶" or " ",
			item.label,
		})
	end

	return {
		ui.Clear(area),
		ui.Border(ui.Border.ALL):area(area):type(ui.Border.ROUNDED):title("My Plugin"),
		ui.Table(rows)
			:area(layout[1])
			:header(ui.Row({ "", "Items" }):style(ui.Style():bold()))
			:row_style(ui.Style():fg("blue"):underline())
			:widths({ ui.Constraint.Length(2), ui.Constraint.Percentage(100) }),
		ui.Block(layout[2]):add(ui.Line(self.state.status):style(ui.Style():fg("green"))),
	}
end

-- Required plugin methods
function M:layout(area)
	self._area = area
end
function M:reflow()
	return { self }
end
function M:click() end
function M:scroll() end
function M:touch() end

return M
