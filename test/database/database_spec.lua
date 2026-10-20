local database = require('treetags.database')

-- TODO no need for this method, you can
-- insert straight to db with ids that I need
local populate_db = function(paths)
    local ids = {}
    local db = database.__get_db()

    for _, path in ipairs(paths) do
        local _, id = db:insert('files', { path = path })
        table.insert(ids, id)
    end

    return ids
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

    it('__drop_db - nil', function()
        database.__drop_db()
        local paths = {
            vim.fs.normalize('meow//woof'),
            vim.fs.normalize('woofs//meow'),
            vim.fs.normalize('woofs//bark'),
        }

        populate_db(paths)
        database.__drop_by_path()
        database.__drop_by_path(nil)
    end)

    it('__drop_db - ""', function()
        database.__drop_db()
        local paths = {
            vim.fs.normalize('meow//woof'),
            vim.fs.normalize('woofs//meow'),
            vim.fs.normalize('woofs//bark'),
        }

        populate_db(paths)
        database.__drop_by_path("")
    end)

    it('__drop_db - can be called on empty db', function()
        database.__drop_db()
        database.__drop_by_path("")
    end)

    it('__drop_db - can be called on non existing path', function()
        database.__drop_db()
        local paths = {
            vim.fs.normalize('meow//woof'),
            vim.fs.normalize('woofs//meow'),
            vim.fs.normalize('woofs//bark'),
        }

        populate_db(paths)
        database.__drop_by_path("cantcatchme")
    end)
end)
