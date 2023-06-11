local class = require("layout.middleclass")

local Tree = class("Tree")

function Tree:initialize(tsnode, parent, root)
  -- tree relevant attributes
	self.tsnode = tsnode
	self.root = root
	self.p = parent
	self.si = 1
	self.c = {}
	self.nc = 0

  -- render relevant attributes
	self.container = true
	self.contents = false
	self.spacer = false
	self.lines = {}
	self.th = 1
	self.tw = 0

  -- current state
	self.state = { open = true, mode = "tree" }
end

return Tree
