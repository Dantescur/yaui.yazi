--- @since 25.2.7

local tx_ui, rx_ui = ya.chan("mpsc")
local tx_pack, rx_pack = ya.chan("mpsc")

local toggle_ui = ya.sync(function(self)
	if self.children then
		Modal:children_remove(self.children)
		self.children = nil
	else
		self.children = Modal:children_add(self, 10)
	end
	ya.render()
end)

local function execute_pack_command(cmd)
	local result = ya.popen("ya pack " .. cmd):read("*a")
	return result
end

local function producer()
	while true do
		local action = rx_ui:recv()
		if action == "quit" then
			toggle_ui()
			break
		end
	end
end

local function pack_consumer()
	while true do
		local command = rx_pack:recv()
		if command then
			local output = execute_pack_command(command)
			print(output) -- Replace with UI feedback later
		end
	end
end

local M = {
	keys = {
		{
			on = "q",
			run = function()
				tx_ui:send("quit")
			end,
		}, -- Quit UI
		{
			on = "i",
			run = function()
				tx_pack:send("install <package>")
			end,
		}, -- Install package
		{
			on = "r",
			run = function()
				tx_pack:send("remove <package>")
			end,
		}, -- Remove package
		{
			on = "l",
			run = function()
				tx_pack:send("list")
			end,
		}, -- List packages
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
	ya.join(producer, pack_consumer)
end

function M:redraw()
	local rows = {
		ui.Row({ "Package", "Version", "Status" }):style(ui.Style():bold()), -- Header
		ui.Row({ "example", "1.0.0", "installed" }), -- Placeholder data
	}

	return {
		ui.Clear(self._area),
		ui.Border(ui.Border.ALL)
			:area(self._area)
			:type(ui.Border.ROUNDED)
			:style(ui.Style():fg("blue"))
			:title(ui.Line("YA Pack Manager"):align(ui.Line.CENTER)),
		ui.Table(rows):area(self._area:pad(ui.Pad(1, 2, 1, 2))):widths({
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
