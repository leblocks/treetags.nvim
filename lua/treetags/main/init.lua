---Options used when rebuilding a treetags database.
---@class TreetagsDatabaseInitParams
---@field extensions? string[] File extensions to parse; empty parses every file returned by fd.
---@field kinds_filter? string[] Definition kinds to exclude; empty stores every kind.
---@field buffer_size? number Entries to buffer before flushing to the database; defaults to 1000.
---@field incremental? boolean Incrementally reparse changed Git-tracked files.

---An indexed Tree-sitter definition.
---@class Treetag
---@field column number
---@field kind string
---@field name string
---@field row number
---@field path string

local BufferedWriter = require('treetags.database.buffer')
local database = require('treetags.database')
local database_utils = require('treetags.database.utils')
local history = require('treetags.parse.history')
local parse = require('treetags.parse')
local parse_utils = require('treetags.parse.utils')
local query = require('treetags.database.query')
local utils = require('treetags.main.utils')

local M = {}

vim.g.treetags_processing = false
vim.g.treetags_debug_level = vim.log.levels.INFO

---Clear and asynchronously rebuild the definition index for the current working directory.
---@param params? TreetagsDatabaseInitParams
M.__init_database = function(params)
    vim.g.treetags_processing = true
    params = params or {}
    local extensions = params.extensions or {}
    local kinds_filter = params.kinds_filter or {}
    local buffer_size = params.buffer_size or 1000
    local incremental = params.incremental or false

    local start = os.time()
    local counter = 0
    local writer = BufferedWriter:new(database.__get_db(), buffer_size)

    local files

    if incremental then
        for _, file in ipairs(parse.__get_changed_source_files(nil, extensions)) do
            utils.__log('dropping ' .. file, '', vim.log.levels.DEBUG)
            database.__drop_by_path(file)
        end

        -- 'd' filter out files that were deleted
        -- so we won't try to reparse those
        files = parse.__get_changed_source_files('d', extensions)
    else
        files = parse.__get_source_files(extensions)
        utils.__log('dropping whole database')
        database.__drop_db()
    end

    -- store new entry in parsing history
    local current_commit = parse_utils.__get_commit_hash()
    history.__add_parse_history_entry(current_commit)

    local finish = function()
        writer:flush()
        utils.__log('creating indexes')
        database.__create_indexes()
        local elapsed = os.difftime(os.time(), start)
        utils.__log('finished processing files ' .. elapsed .. 's elapsed')
        vim.g.treetags_processing = false
    end

    if #files == 0 then
        finish()
        return
    end

    utils.__scheduled_iteration(files, function(_, item, items)
        parse.__parse_file(item, kinds_filter, writer)
        counter = counter + 1

        if counter % 100 == 0 then
            utils.__log(string.format('processed %s/%s of files', counter, #items), '')
        end

        if counter == #items then
            finish()
        end
    end)
end

---Return all indexed definitions.
---@return Treetag[]
M.__get_all_treetags = function()
    local db = database.__get_db()
    return database_utils.__safe_db_call(function()
        return db:eval(query.get_all_tags())
    end)
end

---Return indexed definitions whose name exactly matches `name`.
---@param name? string Name of a treetag.
---@return Treetag[]
M.__get_treetag_by_name = function(name)
    local db = database.__get_db()
    return database_utils.__safe_db_call(function()
        return db:eval(query.get_tags_by_name(name))
    end)
end

---Return indexed definitions whose name contains `name`.
---Matching intentionally remains case-sensitive to preserve source-language identifier casing.
---@param name? string Partial name of a treetag.
---@return Treetag[]
M.__get_treetag_by_name_glob = function(name)
    local db = database.__get_db()
    return database_utils.__safe_db_call(function()
        return db:eval(query.get_tags_by_name_glob(name))
    end)
end

return M
