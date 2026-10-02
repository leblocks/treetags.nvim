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

--- TODO cover in tests
--- AGENT TODO provide documentation
---@return Treetag[]
M.get_treetag_by_name_glob = function(name)
    return utils.__block_on_processing(function()
        return main.__get_treetag_by_name_glob(name)
    end)
end

--- AGENT TODO provide documentation
---@return sqlite_db
M.get_db = function()
    return utils.__block_on_processing(function()
        return database.__get_db()
    end)
end

--- AGENT TODO finish documentation of this class
---@class TreetagPickers object
---@field treetags_all function
---@field treetags_cword function
---@field treetags_cWORD function
---@field treetags_live function

--- AGENT TODO provide documentation
---@param picker_type string Possible values fzf, telescope
---@return TreetagPickers
M.get_pickers = function(picker_type)
    if picker_type == 'fzf' then
        return require('treetags.pickers.fzf')
    elseif picker_type == 'telescope' then
        -- TODO
        return require('treetags.pickers.telescope')
    else
        error('AGENT TODO error message')
    end
end

return M
