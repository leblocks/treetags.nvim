local parse = require('treetags.parse')
local database = require('treetags.database')
local BufferedWriter = require('treetags.database.buffer')

describe('treetags.parse', function()
    it('__parse_file works correctly', function()
        database.__drop_db()
        local writer = BufferedWriter:new(database.__get_db(), 1)
        parse.__parse_file('test/sources/definition.js', writer)

        local db = database.__get_db()

        local rows = db:eval('SELECT * FROM definitions')
        print(vim.inspect(rows))
    end)
end)
