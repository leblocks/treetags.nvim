local database = require('treetags.database')

describe('treetags.database', function()
    it('__get_db returns db object', function()
        local db = database.__get_db()
        assert(db ~= nil)
    end)

    it('__get_db can be called multiple times', function()
        local db1 = database.__get_db()
        local db2 = database.__get_db()
        assert(db1 == db2)
    end)

    it('__drop_db can be called', function()
        database.__drop_db()
    end)
end)
