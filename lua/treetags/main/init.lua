--- AGENT TODO provide clear documentation
---@class TreetagsDatabaseInitParams object
---@field extensions string[] List of file extensions to parse, if empty try to parse everything
---@field kinds_filter string[] List of kinds to not store in database, if empty store every kind, defaults to { 'var' }
---@field buffer_size number Number of entries to buffer before flushing to the database during init

--- AGENT TODO finish documentation of this class
---@class Treetag object
---@field column number
---@field kind string
---@field name string
---@field parser_name string
---@field row number
---@field path string

local parse = require('treetags.parse')
local utils = require('treetags.main.utils')
local database = require('treetags.database')
local query = require('treetags.database.query')
local BufferedWriter = require('treetags.database.buffer')

local M = {}

vim.g.treetags_processing = false

---@param params TreetagsDatabaseInitParams object
M.__init_database = function(params)
    vim.g.treetags_processing = true
    database.__drop_db()
    params = params or {}
    local extensions = params.extensions or {}
    local kinds_filter = params.kinds_filter or { 'var' }
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
            vim.g.treetags_processing = false
        end
    end)
end

--- AGENT TODO provide documentation
---@return Treetag[]
M.__get_all_treetags = function()
    local db = database.__get_db()

    local rows = db:eval(query.get_all_tags())

    if type(rows) ~= "table" then
        return {}
    end

    return rows
end

--- AGENT TODO provide documentation
---@param name string Name of a treetag
---@return Treetag[]
M.__get_treetag_by_name = function(name)
    if name == nil or name == '' then
        return {}
    end

    local db = database.__get_db()

    local rows = db:eval(query.get_tags_by_name(name))

    if type(rows) ~= "table" then
        return {}
    end

    return rows
end

return M
