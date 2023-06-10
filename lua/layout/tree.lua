local M = {}

function M.new(text, data, parent)
	return {
		text = text,
		data = data,
		p = parent,
		c = {},
	}
end

function M.node(tsnode, parent)
	local lines
	if tsnode ~= nil then
		lines = { tsnode:type() }
	else
		lines = {}
	end
	return {
		tsnode = tsnode,
		p = parent,
		lines = lines,
		si = 1,
		c = {},
		nc = 0,
		state = { open = true, mode = "tree" },
	}
end

return M
