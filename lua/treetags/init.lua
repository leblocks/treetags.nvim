local main = require('treetags.main')
local database = require('treetags.database')
local utils = require('treetags.main.utils')

local M = {}

--- AGENT TODO provide documentation
---@param params TreetagsDatabaseInitParams object
M.init_database = function(params)
    utils.__block_on_processing(function()
        main.__init_database(params)
    end)
end

--- AGENT TODO provide documentation
---@return Treetag[]
M.get_all_treetags = function()
    return utils.__block_on_processing(function()
        return main.__get_all_treetags()
    end)
end

--- AGENT TODO provide documentation
---@return Treetag[]
M.get_treetag_by_name = function(name)
    return utils.__block_on_processing(function()
        return main.__get_treetag_by_name(name)
    end)
end

--- AGENT TODO provide documentation
---@return sqlite_db
M.get_db = function()
    return utils.__block_on_processing(function()
        return database.__get_db()
    end)
end

return M
