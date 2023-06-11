local class = require("layout.middleclass")

local a = vim.api
local io = require("layout.io")
local md = require("layout.parsers.md")
local Split = require("nui.split")

local App = class("App")

function App:initialize()
	self.state = {
		open = {},
		wins = {},
		bufs = {},
		trees = {},
		counts = {},
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
	self.cfg_file = vim.fs.normalize("$XDG_CONFIG_HOME/nvim-apps/layout.nvim/config.md")

	-- create a buffer for holding the config
	vim.cmd("e " .. self.cfg_file)
	local buf = a.nvim_get_current_buf()
	local win = a.nvim_get_current_win()
	a.nvim_buf_set_option(buf, "buflisted", false)

	-- update state
	s.bufs.config = buf
	s.wins.config = win
	s.trees.config = md.parse(buf)
	table.insert(s.open, "config")
end

function App:set_dashboard()
	local s = self.state
	local buf = a.nvim_create_buf(false, true)
	local win = a.nvim_get_current_win()
	a.nvim_buf_set_option(buf, "modifiable", false)
	a.nvim_buf_set_name(buf, "dashboard")
	s.wins.dashboard = win
	s.bufs.dashboard = buf
	s.active = "dashboard"
	s.open = { "dashboard" }
	io.set_text(buf, self.dashboard)
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

function App:mount()
	local s = self.state
	local filename = a.nvim_exec2("echo expand('%:p')", { output = true }).output

	-- Set config
	self:set_config()

	-- Set dashboard
	self:set_dashboard()

	-- Create sidebar
	self:create_sidebar()

	-- sidebar_toggle - global
	vim.keymap.set("n", "<C-t>", function()
		s.sidebar_open = not s.sidebar_open
		if s.sidebar_open then
			self.sidebar:show()
		else
			self.sidebar:hide()
		end
	end, { desc = "Toggle sidebar" })

	-- Destroy on quit - global
	vim.keymap.set("n", "<C-q>", function()
		self:unmount()
		vim.cmd([[q!]])
	end, { desc = "Quit all" })

	if filename ~= "" and filename ~= self.cfg_file then
		self:open(filename)
	else
		a.nvim_set_current_buf(s.bufs.dashboard)
		a.nvim_set_current_win(s.wins.dashboard)
	end
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
	vim.cmd("e " .. filename)
	local win = a.nvim_get_current_win()
	local buf = a.nvim_get_current_buf()
	s.wins[filename] = win
	s.bufs[filename] = buf
	s.active = filename

	local tree = md.parse(buf)
	local size = tree.root.size
	md.set_lines(tree, buf, size)
	md.print(tree)
	s.trees[filename] = tree

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
