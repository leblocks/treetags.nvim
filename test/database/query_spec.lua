local query = require('treetags.database.query')
local database = require('treetags.database')

describe('treetags.database.query', function()
    it('can query get_all_tags', function()
        local db = database.__get_db()
        db:eval(query.get_all_tags())
    end)

    it('can query get_tags_by_name - nil', function()
        local db = database.__get_db()
        db:eval(query.get_tags_by_name(nil))
    end)

    it('can query get_tags_by_name - empty string', function()
        local db = database.__get_db()
        db:eval(query.get_tags_by_name(''))
    end)

    it('can query get_tags_by_name - happy path', function()
        local db = database.__get_db()
       db:eval(query.get_tags_by_name('happy path'))
    end)

    it('can query get_tags_by_name_glob - nil', function()
        local db = database.__get_db()
        db:eval(query.get_tags_by_name_glob(nil))
    end)

    it('can query get_tags_by_name_glob - empty string', function()
        local db = database.__get_db()
        db:eval(query.get_tags_by_name_glob(''))
    end)

    it('can query get_tags_by_name_glob - happy path', function()
        local db = database.__get_db()
       db:eval(query.get_tags_by_name_glob('happy path'))
    end)
end)
