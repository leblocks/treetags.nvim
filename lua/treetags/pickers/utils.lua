
local M = {}

---@param entry Treetag
---@return string
M.__format_entry = function(entry)
    return string.format('%-15s %-50s %-30s', '[' .. entry.kind .. ']', entry.name, vim.fs.basename(entry.path))
end

return M
