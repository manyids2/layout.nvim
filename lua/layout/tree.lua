local M = {}

function M.new(text, data, parent)
	return {
		text = text,
		data = data,
		p = parent,
		c = {},
	}
end

return M
