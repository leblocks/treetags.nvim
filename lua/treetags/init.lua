---@class TreetagsDatabaseInitParams object
---@field extensions string[] List of file extensions to parse, if empty try to parse everything
---@field kinds_filter string[] List of kinds to not store in database, if empty store every kind
---@field buffer_size number Number of entries to buffer before flushing to the database during init

---@class TreetagsGetParams object
---@field name string Name of the tag to get, if nil will not filter by name
---@field kind string[] List of kind's to get, if nil or empty will not filter by kind
---@field extensions string[] List of extensions to filter, if nill or empty will not filter

local M = {}

vim.g.treetags_processing = false

---@param params TreetagsDatabaseInitParams object
M.init_database = function(params)
end

---@param params TreetagsGetParams object
M.get_treetags = function(params)
end

return M
