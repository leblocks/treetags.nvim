local utils = require('treetags.database.utils')
local sqlite = require('sqlite.db')

local M = {}

local _db = nil

-- TODO don't forget to normalize paths when writing to db
---@return sqlite_db @Main sqlite.lua object.
local init_db = function()
    return sqlite({
        uri = utils.__get_database_uri(),
        files = {
            id = true,
            path = { type = 'text', unique = true },
        },
        definitions = {
            path_id = { type = 'integer', reference = 'files.id' },
            kind = 'string',
            name = 'text',
            row = 'integer',
            column = 'integer',
            line_content = 'string',
        },
        opts = {
            keep_open = true,
        },
    })
end

---@return sqlite_db @Main sqlite.lua object.
M.__get_db = function()
    if _db ~= nil then
        return _db
    end

    _db = init_db()

    -- dumb performance optimizations
    _db:execute('PRAGMA cache_size = -131072') -- 128MB cache
    _db:execute('PRAGMA journal_mode = OFF')
    _db:execute('PRAGMA synchronous = OFF')
    _db:execute('PRAGMA page_size = 8192')
    _db:execute('PRAGMA mmap_size = 1073741824') -- 1GB mmap
    _db:execute('PRAGMA temp_store = MEMORY')
    _db:execute('PRAGMA optimize')

    return _db
end

M.__create_indexes = function()
    local db = M.__get_db()
    -- TODO indexes!
end

M.__drop_db = function()
    local db = M.__get_db()
    -- TODO drop indexes
    db:eval('delete from definitions')
    db:eval('delete from files')
    db:eval('vacuum')
end

return M
