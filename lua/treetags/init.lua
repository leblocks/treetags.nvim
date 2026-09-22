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

-- TODO tests
--- AGENT TODO provide documentation
M.get_all_treetags = function()
    utils.__block_on_processing(function()
        return main.__get_all_treetags()
    end)
end

-- TODO tests
--- AGENT TODO provide documentation
M.get_treetag_by_name = function(name)
    utils.__block_on_processing(function()
        return main.__get_treetag_by_name(name)
    end)
end

-- TODO tests
--- AGENT TODO provide documentation
M.get_db = function()
    utils.__block_on_processing(function()
        return database.__get_db()
    end)
end

return M
