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

function M:new(area)
	self:layout(area)
	return self
end

function M:layout(area)
	local chunks = ui.Layout()
		:constraints({
			ui.Constraint.Percentage(10),
			ui.Constraint.Percentage(80),
			ui.Constraint.Percentage(10),
		})
		:split(area)

	self._area = chunks[2] -- Set the UI area
end

function M:entry()
	toggle_ui()
	ya.render()
end

function M:redraw()
	local rows = {
		ui.Row({ "Column 1", "Column 2", "Column 3" }):style(ui.Style():bold()), -- Header
		ui.Row({ "Row 1", "Data 1", "Data 2" }),
		ui.Row({ "Row 2", "Data 3", "Data 4" }),
	}

	return {
		ui.Clear(self._area),
		ui.Border(ui.Border.ALL)
			:area(self._area)
			:type(ui.Border.ROUNDED)
			:style(ui.Style():fg("blue"))
			:title(ui.Line("Test UI"):align(ui.Line.CENTER)),
		ui.Table(rows):area(self._area:pad(ui.Pad(1, 2, 1, 2))):widths({
			ui.Constraint.Percentage(30),
			ui.Constraint.Percentage(30),
			ui.Constraint.Percentage(40),
		}),
	}
end

function M:reflow()
	return { self }
end

return M
