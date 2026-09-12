local parse = require('treetags.parse')
local database = require('treetags.database')
local BufferedWriter = require('treetags.database.buffer')

describe('treetags.parse', function()
    it('__parse_file works correctly javascript' function()
        database.__drop_db()
        local writer = BufferedWriter:new(database.__get_db(), 1)
        -- TODO
    end)
end)
