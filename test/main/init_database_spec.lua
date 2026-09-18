local main = require('treetags.main')
local database = require('treetags.database')

describe('treetags.main', function()
    it('__init_databse - default extensions parse all files', function()
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

    it('__init_databse - extensions filters work', function()
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

    it('__init_databse - default kinds_filter filters "var"s', function()
        -- TODO
    end)

    it('__init_databse - kinds_filter works', function()
        -- TODO
    end)
end)
