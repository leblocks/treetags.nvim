local database = require('treetags.database')

local populate_db = function()
    local db = database.__get_db()
    db:insert('files', {
        { id = 1, path = vim.fs.normalize('meow//woof1') },
        { id = 2, path = vim.fs.normalize('meow//woof2') },
        { id = 3, path = vim.fs.normalize('meow//woof3') },
    })
    db:insert('definitions', {
        { path_id = 1, kind = 'cat', name = 'catsky1', row = 0, column = 1 },
        { path_id = 1, kind = 'cat', name = 'catsky2', row = 0, column = 1 },
        { path_id = 2, kind = 'cat', name = 'catsky3', row = 0, column = 1 },
        { path_id = 2, kind = 'cat', name = 'catsky4', row = 0, column = 1 },
        { path_id = 3, kind = 'cat', name = 'catsky5', row = 0, column = 1 },
        { path_id = 3, kind = 'cat', name = 'catsky6', row = 0, column = 1 },
    })
end

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

    it('__drop_db_by_path - nil', function()
        database.__drop_db()
        populate_db()
        database.__drop_by_path()
        database.__drop_by_path(nil)
    end)

    it('__drop_db_by_path - ""', function()
        database.__drop_db()
        populate_db()
        database.__drop_by_path('')
    end)

    it('__drop_db_by_path - can be called on empty db', function()
        database.__drop_db()
        database.__drop_by_path('')
    end)

    it('__drop_db_by_path - can be called on non existing path', function()
        database.__drop_db()
        populate_db()
        database.__drop_by_path('cantcatchme')
    end)

    it('__drop_db_by_path - happy path', function()
        database.__drop_db()
        populate_db()
        database.__drop_by_path(vim.fs.normalize('meow//woof1'))

        local db = database.__get_db()

        -- path_id 1 is for 'meow//woof1'
        local rows = db:eval([[ SELECT * FROM definitions WHERE path_id = 1 ]])
        assert(rows)

        -- path_id 2 is for 'meow//woof2'
        rows = db:eval([[ SELECT * FROM definitions WHERE path_id = 2 ]])
        assert(#rows == 2)

        -- path_id 3 is for 'meow//woof3'
        rows = db:eval([[ SELECT * FROM definitions WHERE path_id = 3 ]])
        assert(#rows == 2)
    end)
end)
