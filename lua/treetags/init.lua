local main = require('treetags.main')
local database = require('treetags.database')
local utils = require('treetags.main.utils')

local M = {}

---Asynchronously build the definition index for the current working directory.
---By default this clears and rebuilds the index; `incremental = true` updates changed Git-tracked files.
---@param params? TreetagsDatabaseInitParams
M.init_database = function(params)
    utils.__block_on_processing(function()
        main.__init_database(params)
    end)
end

---Return all indexed definitions for the current working directory.
---@return Treetag[]
M.get_all_treetags = function()
    return utils.__block_on_processing(function()
        return main.__get_all_treetags()
    end)
end

---Return indexed definitions whose name exactly matches `name`.
---@param name? string
---@return Treetag[]
M.get_treetag_by_name = function(name)
    return utils.__block_on_processing(function()
        return main.__get_treetag_by_name(name)
    end)
end

---Return indexed definitions whose name contains `name` using SQLite GLOB matching.
---@param name? string
---@return Treetag[]
M.get_treetag_by_name_glob = function(name)
    return utils.__block_on_processing(function()
        return main.__get_treetag_by_name_glob(name)
    end)
end

---Return the underlying sqlite.lua database for custom queries.
---@return sqlite_db
M.get_db = function()
    return utils.__block_on_processing(function()
        return database.__get_db()
    end)
end

---Picker functions backed by the treetags index.
---@class TreetagPickers
---@field treetags_all fun(): nil Open a picker containing every indexed definition.
---@field treetags_cword fun(): nil Open exact matches for the word under the cursor.
---@field treetags_cWORD fun(): nil Open exact matches for the WORD under the cursor.
---@field treetags_live fun(): nil Open a live substring-search picker.

---Return the requested optional picker integration.
---@param picker_type '"fzf"'|'"telescope"'
---@return TreetagPickers
M.get_pickers = function(picker_type)
    if picker_type == 'fzf' then
        return require('treetags.pickers.fzf')
    elseif picker_type == 'telescope' then
        return require('treetags.pickers.telescope')
    else
        error(string.format("unknown treetags picker '%s'; expected 'fzf' or 'telescope'", tostring(picker_type)))
    end
end

return M
