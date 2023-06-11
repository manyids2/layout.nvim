local class = require("layout.middleclass")

local Tree = class("Tree")

function Tree:initialize(tsnode, parent, root)
	if parent == nil then
		self.level = 0
	else
		self.level = parent.level + 1
	end
	-- tree relevant attributes
	self.tsnode = tsnode
	self.root = root
	self.p = parent
	self.si = 1
	self.c = {}
	self.nc = 0

	-- render relevant attributes
	self.dtype = "container"
	self.lines = {}
	self.th = 1
	self.tw = 0

	-- current state
	self.state = { open = true, mode = "tree" }
end

function Tree:__tostring()
	return "Tree: [" .. self.tsnode:type() .. ", " .. table.concat(self.lines, " ") .. "]"
end

function Tree:get_dtype_tree(dtype, parent, root)
  local tree
	if self.dtype == dtype then
		tree = Tree:new(self.tsnode, parent, root)
    return tree
	else
		-- look for first content ( it is always wrapped )
		for _, child in ipairs(self.c) do
      print(child)
			local c_child = child:get_dtype_tree(dtype, parent, root)
			if c_child ~= nil then
				return c_child
			end
		end
	end
end

return Tree
