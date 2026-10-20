local utils = require('treetags.main.utils')

describe('utils', function()
    it('__block_on_processing - stops on processing', function()
        vim.g.treetags_processing = true

        local called = false
        utils.__block_on_processing(function()
            called = true
        end)

        assert(not called)

        -- restore global value
        vim.g.treetags_processing = false
    end)

    it('__block_on_processing - returns result', function()
        vim.g.treetags_processing = false
        local called = false
        local result = utils.__block_on_processing(function()
            called = true
            return 42
        end)

        assert(called)
        assert(result == 42)
    end)

    it('__scheduled_iteration - empty table', function()
        local called = false
        utils.__scheduled_iteration({}, function(_, _, _)
            called = true
        end)
        assert(not called)
    end)

    it('__scheduled_iteration - nil', function()
        local called = false
        utils.__scheduled_iteration(nil, function(_, _, _)
            called = true
        end)
        assert(not called)
    end)

    it('__scheduled_iteration - happy path', function()
        local entries = {
            'test',
            'test1',
            'test2',
            'test3',
        }

        local call_count = 0

        utils.__scheduled_iteration(entries, function(i, item, items)
            assert(items[i] == item)
            assert(entries[i] == item)
            assert(#items == #entries)
            call_count = call_count + 1
        end)

        vim.wait(1000, function()
            return call_count == #entries
        end)

        assert(call_count == #entries)
    end)

    it('__escape_ansi - escapes correctly', function()
        local tests = {
            {
                expected_output = 'processed 100/10188 of files',
                input = '^[[?9001h^[[?1004h^[[?25l^[[2J^[[m^[[H^[[?25hprocessed 100/10188 of files',
            },
            {
                expected_output = 'processed 100/448 of files',
                input = '^[[?9001h^[[?1004h^[[?25l^[[2J^[[m^[[H^[[?25hprocessed 100/448 of files',
            },
            {
                expected_output = 'processed 400/448 of files',
                input = 'processed 400/448 of files^[[?9001l^[[?1004l',
            },
            {
                expected_output = 'treetags: "processed 100/10188 of files processed 100/10188 of files',
                input = 'treetags: \27[?9001h\27[?1004h\27[?25l\27[2J\27[m\27[H\27['
                    .. '?25h"processed 100/10188 of files processed 100/10188 of files',
            },
        }

        for _, test in ipairs(tests) do
            assert(test.expected_output, utils.__escape_ansi(test.input))
        end
    end)

    it('__escape_ansi - does not escapes regular string', function()
        assert('test' == utils.__escape_ansi('test'))
    end)
end)
