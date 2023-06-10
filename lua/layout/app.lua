local class = require("layout.middleclass")

local a = vim.api
local io = require("layout.io")
local yaml = require("layout.parsers.yaml")
local Split = require("nui.split")

local App = class("App")

function App:initialize()
	self.state = {
		config = {},
		open = {},
		wins = {},
		bufs = {},
		active = "",
		sidebar_open = false,
	}

	self.dashboard = [[

    hello

]]
end

function App:set_config()
	local s = self.state

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
		s.bufs.config = buf
		s.wins.config = win
		table.insert(s.open, "config")

		-- parse config - throwing away tree for now
		s.config = yaml.config_from_tree(yaml.parse(buf))
	end

	a.nvim_set_current_win(s.wins.dashboard)
	a.nvim_set_current_buf(s.bufs.dashboard)
end

function App:mount()
	local s = self.state
	local filename = a.nvim_exec2("echo expand('%')", { output = true }).output

	local buf, win
	if filename == "" then
		buf = a.nvim_get_current_buf()
	else
		buf = a.nvim_create_buf(false, true)
	end
	a.nvim_buf_set_option(buf, "modifiable", false)
	a.nvim_buf_set_name(buf, "dashboard")

	win = a.nvim_get_current_win()
	s.wins.dashboard = win
	s.bufs.dashboard = buf

	-- Display dashboard
	s.active = "dashboard"
	s.open = { "dashboard" }
	io.set_text(buf, self.dashboard)

	-- Create sidebar
	self:create_sidebar()

	-- sidebar_toggle
	vim.keymap.set("n", "<C-t>", function()
		s.sidebar_open = not s.sidebar_open
		if s.sidebar_open then
			self.sidebar:show()
		else
			self.sidebar:hide()
		end
	end, { desc = "Toggle sidebar", buffer = buf })

	-- Destroy on quit
	vim.keymap.set("n", "q", function()
		self:unmount()
		vim.cmd([[q!]])
	end, { desc = "Quit all", buffer = buf })

	if filename ~= "" then
		self:open(filename)
	end
end

function App:create_sidebar()
	self.sidebar = Split({
		relative = "editor",
		position = "left",
		size = "30%",
	})
	self.sidebar:map("n", "<C-t>", function()
		self.state.sidebar_open = false
		self.sidebar:hide()
	end, {}, true)

	self.sidebar:mount()
	self.sidebar:hide()
end

function App:unmount()
	local s = self.state
	for _, buf in pairs(s.bufs) do
		if a.nvim_buf_is_valid(buf) then
			a.nvim_buf_delete(buf, { force = true })
		end
	end
end

function App:open(filename)
	local s = self.state
	if vim.tbl_contains(s.open, filename) then
		return
	end

	table.insert(s.open, filename)
	local win = a.nvim_get_current_win()
	local buf = a.nvim_get_current_buf()
	s.wins[filename] = win
	s.bufs[filename] = buf
	s.active = filename

	-- sidebar_toggle
	vim.keymap.set("n", "<C-t>", function()
		s.sidebar_open = not s.sidebar_open
		if s.sidebar_open then
			self.sidebar:show()
		else
			self.sidebar:hide()
		end
	end, { desc = "Toggle sidebar", buffer = buf })
end

return App
