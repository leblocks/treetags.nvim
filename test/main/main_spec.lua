local main = require('treetags.main')
local database = require('treetags.database')

describe('treetags.main', function()
    it('__get_all_treetags - happy path', function()
        database.__drop_db()
        main.__init_database()
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local tags = main.__get_all_treetags()
        assert(#tags > 0)

        -- every tag entry has path field populated
        for _, tag in ipairs(tags) do
            assert(tag.path ~= nil)
            assert(tag.path ~= '')
        end
    end)

    it('__get_all_treetags - on empty db returns empty result', function()
        database.__drop_db()
        local tags = main.__get_all_treetags()
        assert(#tags == 0)
    end)

    it('__get_treetag_by_name - on empty db returns empty result', function()
        database.__drop_db()
        local tags = main.__get_treetag_by_name('sometag')
        assert(#tags == 0)
    end)

    it('__get_treetag_by_name - on nil returns empty result', function()
        database.__drop_db()
        local tags = main.__get_treetag_by_name(nil)
        assert(#tags == 0)
    end)

    it('__get_treetag_by_name - on empty string returns empty result', function()
        database.__drop_db()
        local tags = main.__get_treetag_by_name('')
        assert(#tags == 0)
    end)

    it('__get_treetag_by_name - happy path', function()
        database.__drop_db()
        local tags = main.__get_treetag_by_name('')
        main.__init_database()
        vim.wait(5000, function()
            return not vim.g.treetags_processing
        end)

        local tags = main.__get_treetag_by_name('enqueue')
        assert(#tags == 1)
        assert(tags[1].name == 'enqueue')
        assert(tags[1].column == 4)
        assert(tags[1].row == 13)
        assert(tags[1].path == 'test/sources/definition.js')
        assert(tags[1].kind == 'function')
        assert(tags[1].parser_name == 'javascript')

        tags = main.__get_treetag_by_name('Main')
        assert(#tags == 1)
        assert(tags[1].name == 'Main')
        assert(tags[1].column == 16)
        assert(tags[1].row == 5)
        assert(tags[1].path == 'test/sources/definition.cs')
        assert(tags[1].kind == 'method')
        assert(tags[1].parser_name == 'c_sharp')
    end)
end)
