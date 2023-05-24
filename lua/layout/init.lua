local a = vim.api
local io = require("layout.io")

local app = {}

app.state = {
	config = {},
	open = {},
	wins = {},
	bufs = {},
	active = "",
}

app.dashboard = [[

    hello

]]

function app.load_config(self)
	-- load config file using XDG_CONFIG_HOME
	local output = a.nvim_exec2("!echo $XDG_CONFIG_HOME", { output = true }).output
	self.xdg_dir = vim.split(output, "\n", {})[3]
	self.src_dir = self.xdg_dir .. "/nvim-apps/layout.nvim"
	local pathlist = vim.fs.find("config.yaml", { upward = false, path = self.src_dir })
	if vim.tbl_count(pathlist) > 0 then
		self.cfg_file = pathlist[1]

		-- create a buffer for holding the config
		vim.cmd("e " .. self.cfg_file)
		local buf = a.nvim_get_current_buf()
		local win = a.nvim_get_current_win()
		a.nvim_buf_set_option(buf, "buflisted", false)

		local s = self.state
		s.bufs.config = buf
		s.wins.config = win
		table.insert(s.open, "config")

		-- parse the config to tree
		s.config = {}
	else
		return
	end
end

function app.mount(self)
	local s = self.state

	-- Unlist empty buffer
	local buf = a.nvim_get_current_buf()
	local win = a.nvim_get_current_win()
	s.wins.dashboard = win
	s.bufs.dashboard = buf
	a.nvim_buf_set_option(buf, "buflisted", false)

	-- Display dashboard
	s.active = "dashboard"
	s.open = { "dashboard" }
	io.set_text(buf, self.dashboard)

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
		app:load_config()
		P(app.cfg_file)
		return
	end

	local s = app.state
	table.insert(s.open, filename)
	local win = a.nvim_get_current_win()
	local buf = a.nvim_get_current_buf()
	s.wins[filename] = win
	s.bufs[filename] = buf
	s.active = filename

	return app
end

return app
