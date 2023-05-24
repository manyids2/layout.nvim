local a = vim.api
local io = require("layout.io")

local app = {}

app.state = {
	open = {},
	wins = {},
	bufs = {},
}

app.dashboard = [[

    hello

]]

function app.mount(self)
	local s = self.state

	-- Unlist empty buffer
	local buf = a.nvim_get_current_buf()
	a.nvim_buf_set_option(buf, "buflisted", false)

	-- Display dashboard
	io.set_text(buf, self.dashboard)
	s.bufs.config = buf

	-- Destroy on quit
	vim.keymap.set("n", "q", function()
		self:unmount()
		vim.cmd([[q!]])
	end, { desc = "Quit all", buffer = buf })
end

function app.unmount(self)
	local s = self.state
	for _, buf in pairs(s.bufs) do
		a.nvim_buf_delete(buf, { force = true })
	end
end

function app.setup()
	local filename = a.nvim_exec2("echo expand('%')", { output = true }).output
	if filename == "" then
		app:mount()
		return
	end
	local s = app.state
	table.insert(s.open, filename)

	P(app.state)
	return app
end

return app
