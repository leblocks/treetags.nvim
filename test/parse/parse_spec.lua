local parse = require('treetags.parse')

describe('treetags.parse', function()
    it('__get_source_files no arguments', function()
        local files = parse.__get_source_files()
        assert(#files > 0)
    end)

    it('__get_source_files nil', function()
        local files = parse.__get_source_files(nil)
        assert(#files > 0)
    end)

    it('__get_source_files empty', function()
        local files = parse.__get_source_files({})
        assert(#files > 0)
    end)

    it('__get_source_files lua', function()
        local files = parse.__get_source_files({ 'lua' })
        local lua_files_count = 0

        for _, file in ipairs(files) do
            if file:match('lua$') then
                lua_files_count = lua_files_count + 1
            end
        end

        assert(#files == lua_files_count)
    end)

    it('__get_source_files lua and md', function()
        local files = parse.__get_source_files({ 'lua', 'md' })
        local lua_files_count = 0

        for _, file in ipairs(files) do
            if file:match('lua$') or file:match('md$') then
                lua_files_count = lua_files_count + 1
            end
        end

        assert(#files == lua_files_count)
    end)
end)
