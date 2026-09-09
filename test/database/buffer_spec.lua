local database = require('treetags.database')
local BufferedWriter = require('treetags.database.buffer')

describe('treetags.database.buffer', function()
    it('buffer will not write until buffer limit reached', function()
        database.__drop_db()

        local db = database.__get_db()
        local writer = BufferedWriter:new(database.__get_db(), 10)

        writer:add_to_buffer('definitions', { name = 'Test' })
        writer:add_to_buffer('definitions', { name = 'Test' })
        writer:add_to_buffer('definitions', { name = 'Test' })

        local defcount = db:eval([[ select count(*) from definitions ]])
        assert(defcount[1]['count(*)'] == 0)
    end)

    it('buffer will write when buffer limit reached', function()
        database.__drop_db()

        local db = database.__get_db()
        local writer = BufferedWriter:new(database.__get_db(), 5)

        writer:add_to_buffer('definitions', { name = 'Test' })
        writer:add_to_buffer('definitions', { name = 'Test' })
        writer:add_to_buffer('definitions', { name = 'Test' })
        writer:add_to_buffer('definitions', { name = 'Test' })
        writer:add_to_buffer('definitions', { name = 'Test' })

        local defcount = db:eval([[ select count(*) from definitions ]])
        assert(defcount[1]['count(*)'] == 5)
    end)

    it('buffer will flush when requested', function()
        database.__drop_db()

        local db = database.__get_db()
        local writer = BufferedWriter:new(database.__get_db(), 5)

        writer:add_to_buffer('definitions', { name = 'Test' })
        writer:add_to_buffer('definitions', { name = 'Test' })
        writer:flush()

        local defcount = db:eval([[ select count(*) from definitions ]])
        assert(defcount[1]['count(*)'] == 2)
    end)

    it('buffer will write to different tables', function()
        database.__drop_db()

        local db = database.__get_db()
        local writer = BufferedWriter:new(database.__get_db(), 5)

        writer:add_to_buffer('definitions', { name = 'Test' })
        writer:add_to_buffer('files', { path = 'Test' })
        writer:flush()

        local def_count = db:eval([[ select count(*) from definitions ]])
        local file_count = db:eval([[ select count(*) from files ]])
        assert(def_count[1]['count(*)'] == 1)
        assert(file_count[1]['count(*)'] == 1)
    end)
end)
