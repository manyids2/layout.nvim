local class = require("layout.middleclass")

local a = vim.api
local Tree = class("Tree")

function Tree:initialize(tsnode, parent, root)
	self.tsnode = tsnode
	self.root = root
	self.p = parent
	self.si = 1
	self.c = {}
	self.nc = 0
	self.index = 0
	if parent then
		self.level = parent.level + 1
	else
		self.level = 0
	end
	self.dtype = "container"
	self.lines = {}
end

function Tree:get_node_lines(buf, size)
	local sr, sc, er, ec = self.tsnode:range()
	if er >= size then
		er = er - 1
	end
	if sr == er then
		sc = math.min(sc, ec)
	end
	-- trim and return
	local tlines = {}
	local lines = a.nvim_buf_get_text(buf, sr, sc, er, ec, {})
	for _, line in ipairs(lines) do
		table.insert(tlines, vim.trim(line))
	end
	return tlines
end

function Tree:set_lines(buf, size, get_data)
	local n = self.tsnode
	if n then
		local data = get_data[n:type()](self, buf, size)
		self.lines = data.lines
		self.dtype = data.dtype
	end
	for _, child in ipairs(self.c) do
		child:set_lines(buf, size, get_data)
	end
end

function Tree:setup_children(root, dtypes)
	for child in self.tsnode:iter_children() do
		local cnode = Tree:new(child, self, root)
		table.insert(self.c, cnode:setup_children(root, dtypes))
	end
	self.dtype = dtypes[self.tsnode:type()]
	return self
end

function Tree:re_index(root, p_index)
	-- root, index, level, si, nc
	self.root = root
	self.index = p_index
	self.nc = vim.tbl_count(self.c)
	if self.p then
		self.level = self.p.level + 1
	else
		self.level = 0
	end
	for si, child in ipairs(self.c) do
		child.si = si
		p_index = p_index + 1
		p_index = child:re_index(root, p_index)
	end
	return p_index
end

function Tree:print(dtype)
	if self.tsnode then
		if not dtype then
			print(self)
		elseif dtype == self.dtype then
			print(self)
		end
		for _, child in ipairs(self.c) do
			child:print(dtype)
		end
	end
end

function Tree:__tostring()
	local padding = string.rep("  ", self.level)
	local out = padding .. tostring(self.index) .. ", " .. self.tsnode:type()
	if self.lines then
		out = out .. ", " .. table.concat(self.lines, " ")
	end
	return out
end

return Tree
