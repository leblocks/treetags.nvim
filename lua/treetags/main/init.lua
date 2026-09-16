---@class TreetagsDatabaseInitParams object
---@field extensions string[] List of file extensions to parse, if empty try to parse everything
---@field kinds_filter string[] List of kinds to not store in database, if empty store every kind
---@field buffer_size number Number of entries to buffer before flushing to the database during init

local parse = require('treetags.parse')
local utils = require('treetags.main.utils')
local database = require('treetags.database')
local BufferedWriter = require('treetags.database.buffer')

local M = {}

---@param params TreetagsDatabaseInitParams object
M.__init_database = function(params)
    -- TODO validate default values
    local extensions = params.extensions or {}
    local kinds_filter = params.kinds_filter or {}
    local buffer_size = params.buffer_size or 1000

    local counter = 0
    local writer = BufferedWriter:new(database.__get_db(), buffer_size)
    local files = parse.__get_source_files(extensions)

    utils.__scheduled_iteration(files, function(_, item, items)
        parse.__parse_file(item, kinds_filter, writer)
        counter = counter + 1

        if counter % 100 == 0 then
            utils.__log(string.format('processed %s/%s of files', counter, #items), '')
        end

        if counter == #items then
            writer:flush()
            utils.__log('creating indexes', '')
            database.__create_indexes()
        end
    end)
end

return M
