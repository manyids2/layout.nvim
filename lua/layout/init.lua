local class = require("layout.middleclass")

local a = vim.api
local io = require("layout.io")
local yaml = require("layout.parsers.yaml")

local App = class("App")

function App:initialize()
	self.state = {
		config = {},
		open = {},
		wins = {},
		bufs = {},
		active = "",
	}

	self.dashboard = [[

    hello

]]
end

function App:set_config()
	-- load config file using XDG_CONFIG_HOME
	local output = a.nvim_exec2("!echo $XDG_CONFIG_HOME", { output = true }).output
	self.xdg_dir = vim.split(output, "\n", {})[3]
	self.src_dir = self.xdg_dir .. "/nvim-apps/layout.nvim"

	-- if found config.yaml
	local pathlist = vim.fs.find("config.yaml", { upward = false, path = self.src_dir })
	if vim.tbl_count(pathlist) > 0 then
		self.cfg_file = pathlist[1]

		-- create a buffer for holding the config
		vim.cmd("e " .. self.cfg_file)
		local buf = a.nvim_get_current_buf()
		local win = a.nvim_get_current_win()
		a.nvim_buf_set_option(buf, "buflisted", false)

		-- update state
		local s = self.state
		s.bufs.config = buf
		s.wins.config = win
		table.insert(s.open, "config")

		-- parse config - throwing away tree for now
		s.config = yaml.config_from_tree(yaml.parse(buf))
	else
		return
	end
end

function App:mount()
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

function App:unmount()
	local s = self.state
	for _, buf in pairs(s.bufs) do
		a.nvim_buf_delete(buf, { force = true })
	end
end

function App:open()
	local s = self.state
	local filename = a.nvim_exec2("echo expand('%')", { output = true }).output
	if filename == "" then
		return
	end
	if vim.tbl_contains(s.open, filename) then
		return
	end

	table.insert(s.open, filename)
	local win = a.nvim_get_current_win()
	local buf = a.nvim_get_current_buf()
	s.wins[filename] = win
	s.bufs[filename] = buf
	s.active = filename
	P(s.open)
end

return App
