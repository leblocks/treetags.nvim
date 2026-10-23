local utils = require('treetags.database.utils')

describe('treetags.database.utils', function()
    it('__get_db_file_name works for windows path', function()
        local name = utils.__get_db_file_name('C:\\Users\\john\\repos\\dotfiles')
        assert(name == 'C--Users-john-repos-dotfiles.treetags.sql')
    end)

    it('__get_db_file_name works for linux path', function()
        local name = utils.__get_db_file_name('/home/john/nvim')
        assert(name == 'home-john-nvim.treetags.sql')
    end)

    it('__safe_db call - returns {} on failure', function()
        assert(#utils.__safe_db_call() == 0)
        assert(#utils.__safe_db_call(function()
            return false
        end) == 0)
        assert(#utils.__safe_db_call(function()
            error('wont see me')
        end) == 0)
    end)

    it('__safe_db call - happy path', function()
        local dummy = function()
            return { 'apple', 'banana' }
        end

        local actual = utils.__safe_db_call(dummy)

        assert(actual[1] == 'apple')
        assert(actual[2] == 'banana')
    end)
end)
