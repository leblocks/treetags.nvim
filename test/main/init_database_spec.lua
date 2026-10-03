local main = require('treetags.main')
local database = require('treetags.database')

describe('treetags.main', function()
    it('__init_database - default extensions parse all files', function()
        database.__drop_db()
        main.__init_database()
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local db = database.__get_db()

        local rows = db:eval([[ SELECT DISTINCT parser_name FROM definitions ORDER BY parser_name ]])
        assert(rows[1].parser_name == 'c_sharp')
        assert(rows[2].parser_name == 'javascript')
        assert(rows[3].parser_name == 'lua')
    end)

    it('__init_database - extensions filters work', function()
        database.__drop_db()
        main.__init_database({ extensions = { 'cs' } })
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local db = database.__get_db()

        local rows = db:eval([[ SELECT DISTINCT parser_name FROM definitions ORDER BY parser_name ]])
        assert(rows[1].parser_name == 'c_sharp')
        assert(#rows == 1)
    end)

    it('__init_database - kinds_filter works', function()
        database.__drop_db()
        main.__init_database({ kinds_filter = { 'function', 'var' } })
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local db = database.__get_db()

        local rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE kind = 'function' ]])
        assert(rows[1]['COUNT(1)'] == 0)

        rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE kind = 'var' ]])
        assert(rows[1]['COUNT(1)'] == 0)
    end)

    it('__init_database - populates database', function()
        database.__drop_db()
        main.__init_database()
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local db = database.__get_db()

        local rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE kind IS NULL ]])
        assert(rows[1]['COUNT(1)'] == 0)

        rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE parser_name IS NULL ]])
        assert(rows[1]['COUNT(1)'] == 0)

        rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE name IS NULL ]])
        assert(rows[1]['COUNT(1)'] == 0)

        rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE row IS NULL ]])
        assert(rows[1]['COUNT(1)'] == 0)

        rows = db:eval([[ SELECT COUNT(1) FROM definitions WHERE column IS NULL ]])
        assert(rows[1]['COUNT(1)'] == 0)
    end)
end)
