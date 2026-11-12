local M = {}

---@param entry Treetag
---@return string
M.__format_entry = function(entry)
    return string.format('%-15s %-50s %-30s', '[' .. entry.kind .. ']', entry.name, vim.fs.basename(entry.path))
end

---Format a file entry for picker display.
---@param entry TreetagFile|{path: string}
---@return string
M.__format_path_entry = function(entry)
    return entry.path
end

return M
