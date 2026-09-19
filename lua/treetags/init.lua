local main = require('treetags.main')
local utils = require('treetags.main.utils')

local M = {}

---@param params TreetagsDatabaseInitParams object
M.init_database = function(params)
    utils.__block_on_processing(function()
        main.__init_database(params)
    end)
end

---@param params TreetagsGetParams object
M.get_treetags = function(params)
    utils.__block_on_processing(function()
        return main.__get_treetags(params)
    end)
end

return M
