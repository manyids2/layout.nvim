local class = require("layout.middleclass")

local Tree = class("Tree")

function Tree:initialize(tsnode, parent, root)
	local lines, range
	if tsnode ~= nil then
		lines = { tsnode:type() }
		range = tsnode:range(false)
	else
		lines = { " " }
	end
	self.th = 1
	self.tw = string.len(lines[1])
	self.tsnode = tsnode
	self.root = root
	self.p = parent
	self.lines = lines
	self.range = range
	self.si = 1
	self.c = {}
	self.nc = 0
	self.state = { open = true, mode = "tree" }
end

return Tree
