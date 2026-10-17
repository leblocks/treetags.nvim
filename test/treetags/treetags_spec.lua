local database = require('treetags.database')

describe('treetags', function()
    it('init_databse - default extensions parse all files', function()
        database.__drop_db()
        require('treetags').init_database()
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local db = database.__get_db()

        local extensions = db:eval([[
            SELECT DISTINCT substr(path, instr(path, '.') + 1) AS extension
            FROM files
            ORDER BY path
        ]])
        -- TODO make better assertion
        assert(#extensions > 3)
    end)

    it('init_databse - extensions filters work', function()
        database.__drop_db()
        require('treetags').init_database({ extensions = { 'cs' } })
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local db = database.__get_db()

        local files = db:eval([[
            SELECT DISTINCT substr(path, instr(path, '.') + 1) AS extension
            FROM files
            ORDER BY path
        ]])
        assert(files[1].extension == 'cs')
        assert(#files == 1)
    end)

    it('init_databse - kinds_filter works', function()
        database.__drop_db()
        require('treetags').init_database({ kinds_filter = { 'function', 'var' } })
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local db = database.__get_db()

        local rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE kind = 'function' ]])
        assert(rows[1]['COUNT(1)'] == 0)

        rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE kind = 'var' ]])
        assert(rows[1]['COUNT(1)'] == 0)
    end)

    it('init_databse - populates database', function()
        database.__drop_db()
        require('treetags').init_database()
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local db = database.__get_db()

        local rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE kind IS NULL ]])
        assert(rows[1]['COUNT(1)'] == 0)

        rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE name IS NULL ]])
        assert(rows[1]['COUNT(1)'] == 0)

        rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE row IS NULL ]])
        assert(rows[1]['COUNT(1)'] == 0)

        rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE column IS NULL ]])
        assert(rows[1]['COUNT(1)'] == 0)
    end)

    it('get_all_treetags - happy path', function()
        database.__drop_db()
        require('treetags').init_database()
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local tags = require('treetags').get_all_treetags()
        assert(#tags > 0)

        -- every tag entry has path field populated
        for _, tag in ipairs(tags) do
            assert(tag.path ~= nil)
            assert(tag.path ~= '')
        end
    end)

    it('get_all_treetags - on empty db returns empty result', function()
        database.__drop_db()
        local tags = require('treetags').get_all_treetags()
        assert(#tags == 0)
    end)

    it('get_treetag_by_name - on empty db returns empty result', function()
        database.__drop_db()
        local tags = require('treetags').get_treetag_by_name('sometag')
        assert(#tags == 0)
    end)

    it('get_treetag_by_name - on nil returns empty result', function()
        database.__drop_db()
        local tags = require('treetags').get_treetag_by_name(nil)
        assert(#tags == 0)
    end)

    it('get_treetag_by_name - on empty string returns empty result', function()
        database.__drop_db()
        local tags = require('treetags').get_treetag_by_name('')
        assert(#tags == 0)
    end)

    it('get_treetag_by_name - happy path', function()
        database.__drop_db()
        require('treetags').init_database()
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local tags = require('treetags').get_treetag_by_name('enqueue')
        assert(#tags == 1)
        assert(tags[1].name == 'enqueue')
        assert(tags[1].column == 4)
        assert(tags[1].row == 13)
        assert(tags[1].path == 'test/sources/definition.js')
        assert(tags[1].kind == 'function')

        tags = require('treetags').get_treetag_by_name('Main')
        assert(#tags == 1)
        assert(tags[1].name == 'Main')
        assert(tags[1].column == 16)
        assert(tags[1].row == 5)
        assert(tags[1].path == 'test/sources/definition.cs')
        assert(tags[1].kind == 'method')
    end)

    it('get_db - schema is created', function()
        database.__drop_db()
        local db = require('treetags').get_db()
        assert(db:exists('files'))
        assert(db:table('files'):count() == 0)
        assert(db:exists('definitions'))
        assert(db:table('definitions'):count() == 0)
    end)

    it('get_db - can be called multiple times', function()
        local db1 = require('treetags').get_db()
        local db2 = require('treetags').get_db()
        assert(db1 == db2)
    end)
end)
