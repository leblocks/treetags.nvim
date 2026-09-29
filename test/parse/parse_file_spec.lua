local parse = require('treetags.parse')
local database = require('treetags.database')
local BufferedWriter = require('treetags.database.buffer')

describe('treetags.parse', function()
    it('__parse_file populates db - nil filtered_kinds', function()
        database.__drop_db()
        local writer = BufferedWriter:new(database.__get_db(), 1)
        parse.__parse_file('test/sources/definition.js', nil, writer)

        local db = database.__get_db()
        local rows = db:eval('SELECT * FROM definitions')

        assert(#rows > 0)
        for _, row in ipairs(rows) do
            assert(row.column ~= nil)
            assert(row.row ~= nil)
            assert(row.name ~= nil)
            assert(row.parser_name ~= nil)
            assert(row.path_id ~= nil)
            assert(row.kind ~= nil)
            assert(not row.kind:match('^local.definition'))
        end
    end)

    it('__parse_file populates db - empty filtered_kinds', function()
        database.__drop_db()
        local writer = BufferedWriter:new(database.__get_db(), 1)
        parse.__parse_file('test/sources/definition.js', {}, writer)

        local db = database.__get_db()
        local rows = db:eval('SELECT * FROM definitions')

        assert(#rows > 0)
        for _, row in ipairs(rows) do
            assert(row.column ~= nil)
            assert(row.row ~= nil)
            assert(row.name ~= nil)
            assert(row.parser_name ~= nil)
            assert(row.path_id ~= nil)
            assert(row.kind ~= nil)
            assert(not row.kind:match('^local.definition'))
        end
    end)

    it('__parse_file populates db - kinds filter', function()
        database.__drop_db()
        local writer = BufferedWriter:new(database.__get_db(), 1)
        parse.__parse_file('test/sources/definition.js', { 'var' }, writer)

        local db = database.__get_db()
        local rows = db:eval('SELECT * FROM definitions')

        assert(#rows > 0)
        for _, row in ipairs(rows) do
            assert(row.column ~= nil)
            assert(row.row ~= nil)
            assert(row.name ~= nil)
            assert(row.parser_name ~= nil)
            assert(row.path_id ~= nil)
            assert(row.kind ~= 'var')
        end
    end)
end)
